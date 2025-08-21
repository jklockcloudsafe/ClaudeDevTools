#!/bin/bash
# Property of CloudSafe
# claude-session.sh - Repository-specific Claude session management
#
# This tool manages Claude Code conversation sessions by capturing and storing:
# - Git repository state (branch, commit hash, working directory)
# - Project context (presence of CLAUDE.md, PROJECT_CONTEXT.md, .claude.json)
# - Session metadata (timestamp, repository name, session notes)
# - Sessions are stored in .claude/sessions/ within each repository
#
# When you resume a session, you get context about:
# - What branch you were working on
# - What commit you were at
# - What project configuration was present
# - When the session was created
#
# This helps Claude Code understand the project state when you return to work.

set -e

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS] [action]"
    echo ""
    echo "Manage Claude conversation sessions for current repository"
    echo ""
    echo "Actions:"
    echo "  save [name]         Save current session with optional name"
    echo "  list               List all sessions for this repository"
    echo "  show <name>        Show session details"
    echo "  resume <name>      Resume a previous session"
    echo "  delete <name>      Delete a session"
    echo "  export <name>      Export session to markdown"
    echo "  clean              Remove old sessions (>30 days)"
    echo ""
    echo "Options:"
    echo "  --install          Install as global 'claude-session' command"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 save             # Save current session with auto-generated name"
    echo "  $0 save feature-x   # Save with specific name"
    echo "  $0 list             # List all sessions in this repo"
    echo "  $0 resume feature-x # Resume the feature-x session"
    echo "  $0 export feature-x # Export session to markdown file"
    exit 1
}

# Function to install globally
install_globally() {
    local script_name="$1"
    local target_command="$2"
    
    # Create bin directory if it doesn't exist
    mkdir -p ~/bin
    
    # Check if command already exists
    if [[ -f ~/bin/$target_command ]]; then
        echo "Command $target_command already installed"
        echo "Updating $target_command script..."
    else
        echo "Installing $target_command script..."
    fi
    
    # Copy current script to ~/bin with new name
    cp "$0" ~/bin/$target_command
    chmod +x ~/bin/$target_command
    
    # Ensure ~/bin is in PATH (idempotent)
    export PATH="$HOME/bin:$PATH"
    
    # Add PATH to ~/.zshrc if not already present
    if ! grep -q 'export PATH="$HOME/bin:$PATH"' ~/.zshrc 2>/dev/null; then
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
        echo "Added ~/bin to PATH in ~/.zshrc"
    else
        echo "PATH already configured in ~/.zshrc"
    fi
    
    echo "$target_command installed and ready!"
    echo "Usage: Run '$target_command' from anywhere in a git repository"
    echo "Restart your terminal or run 'source ~/.zshrc' to use immediately"
    
    exit 0
}

# Check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not in a git repository. Claude sessions are repository-specific."
        exit 1
    fi
}

# Get repository root and name
get_repo_info() {
    REPO_ROOT=$(git rev-parse --show-toplevel)
    REPO_NAME=$(basename "$REPO_ROOT")
    SESSION_DIR="$REPO_ROOT/.claude/sessions"
    mkdir -p "$SESSION_DIR"
}

# Generate session name with timestamp
generate_session_name() {
    echo "session_$(date +%Y%m%d_%H%M%S)"
}

# Save current session
save_session() {
    local session_name="$1"
    if [[ -z "$session_name" ]]; then
        session_name=$(generate_session_name)
    fi
    
    local session_file="$SESSION_DIR/$session_name.json"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    local commit=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
    
    # Create session metadata
    cat > "$session_file" << EOF
{
  "name": "$session_name",
  "repository": "$REPO_NAME",
  "timestamp": "$timestamp",
  "branch": "$branch",
  "commit": "$commit",
  "context": {
    "working_directory": "$REPO_ROOT",
    "project_context": "$(if [[ -f "$REPO_ROOT/PROJECT_CONTEXT.md" ]]; then echo "present"; else echo "missing"; fi)",
    "claude_config": "$(if [[ -f "$REPO_ROOT/.claude.json" ]]; then echo "present"; else echo "missing"; fi)"
  },
  "notes": ""
}
EOF
    
    echo "Session saved: $session_name"
    echo "File: $session_file"
    echo "Repository: $REPO_NAME"
    echo "Branch: $branch"
}

# List all sessions
list_sessions() {
    if [[ ! -d "$SESSION_DIR" ]] || [[ -z "$(ls -A "$SESSION_DIR" 2>/dev/null)" ]]; then
        echo "No sessions found for repository: $REPO_NAME"
        return
    fi
    
    echo "Sessions for repository: $REPO_NAME"
    echo "======================================="
    
    for session_file in "$SESSION_DIR"/*.json; do
        if [[ -f "$session_file" ]]; then
            local name=$(basename "$session_file" .json)
            local timestamp=$(jq -r '.timestamp // "unknown"' "$session_file" 2>/dev/null || echo "unknown")
            local branch=$(jq -r '.branch // "unknown"' "$session_file" 2>/dev/null || echo "unknown")
            
            echo "$name"
            echo "  Created: $timestamp"
            echo "  Branch: $branch"
            echo ""
        fi
    done
}

# Show session details
show_session() {
    local session_name="$1"
    local session_file="$SESSION_DIR/$session_name.json"
    
    if [[ ! -f "$session_file" ]]; then
        echo "Error: Session '$session_name' not found"
        exit 1
    fi
    
    echo "Session Details: $session_name"
    echo "==============================="
    
    if command -v jq >/dev/null 2>&1; then
        jq . "$session_file"
    else
        cat "$session_file"
    fi
}

# Resume session
resume_session() {
    local session_name="$1"
    local session_file="$SESSION_DIR/$session_name.json"
    
    if [[ ! -f "$session_file" ]]; then
        echo "Error: Session '$session_name' not found"
        exit 1
    fi
    
    echo "Resuming session: $session_name"
    echo "==============================="
    
    # Show session context
    local timestamp=$(jq -r '.timestamp // "unknown"' "$session_file" 2>/dev/null || echo "unknown")
    local branch=$(jq -r '.branch // "unknown"' "$session_file" 2>/dev/null || echo "unknown")
    local commit=$(jq -r '.commit // "unknown"' "$session_file" 2>/dev/null || echo "unknown")
    
    echo "Session created: $timestamp"
    echo "Original branch: $branch"
    echo "Original commit: $commit"
    echo ""
    echo "Current context:"
    echo "- Repository: $REPO_NAME"
    echo "- Current branch: $(git branch --show-current 2>/dev/null || echo "unknown")"
    echo "- Current commit: $(git rev-parse --short HEAD 2>/dev/null || echo "unknown")"
    echo ""
    echo "To continue this session, run 'claude' and reference this context."
    echo "Session file: $session_file"
}

# Delete session
delete_session() {
    local session_name="$1"
    local session_file="$SESSION_DIR/$session_name.json"
    
    if [[ ! -f "$session_file" ]]; then
        echo "Error: Session '$session_name' not found"
        exit 1
    fi
    
    rm "$session_file"
    echo "Session deleted: $session_name"
}

# Export session to markdown
export_session() {
    local session_name="$1"
    local session_file="$SESSION_DIR/$session_name.json"
    local export_file="$REPO_ROOT/${session_name}_export.md"
    
    if [[ ! -f "$session_file" ]]; then
        echo "Error: Session '$session_name' not found"
        exit 1
    fi
    
    # Create markdown export
    cat > "$export_file" << EOF
# Claude Session Export: $session_name

**Repository:** $REPO_NAME  
**Created:** $(jq -r '.timestamp // "unknown"' "$session_file" 2>/dev/null || echo "unknown")  
**Branch:** $(jq -r '.branch // "unknown"' "$session_file" 2>/dev/null || echo "unknown")  
**Commit:** $(jq -r '.commit // "unknown"' "$session_file" 2>/dev/null || echo "unknown")  

## Session Context

\`\`\`json
$(cat "$session_file")
\`\`\`

## Notes

Add your conversation notes and context here...

EOF
    
    echo "Session exported to: $export_file"
}

# Clean old sessions
clean_sessions() {
    if [[ ! -d "$SESSION_DIR" ]]; then
        echo "No sessions directory found"
        return
    fi
    
    local count=0
    find "$SESSION_DIR" -name "*.json" -mtime +30 -type f | while read -r session_file; do
        local name=$(basename "$session_file" .json)
        echo "Removing old session: $name"
        rm "$session_file"
        ((count++))
    done
    
    if [[ $count -eq 0 ]]; then
        echo "No old sessions found (>30 days)"
    else
        echo "Removed $count old sessions"
    fi
}

# Parse command line arguments
ACTION=""
SESSION_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --install)
            install_globally "$(basename "$0")" "claude-session"
            ;;
        -h|--help)
            usage
            ;;
        save|list|show|resume|delete|export|clean)
            ACTION="$1"
            shift
            if [[ "$ACTION" != "list" && "$ACTION" != "clean" && $# -gt 0 && ! "$1" =~ ^- ]]; then
                SESSION_NAME="$1"
                shift
            fi
            ;;
        *)
            echo "Error: Unknown option or action: $1"
            usage
            ;;
    esac
done

# Validate action
if [[ -z "$ACTION" ]]; then
    echo "Error: No action specified"
    usage
fi

# Check for required session name
if [[ "$ACTION" == "show" || "$ACTION" == "resume" || "$ACTION" == "delete" || "$ACTION" == "export" ]] && [[ -z "$SESSION_NAME" ]]; then
    echo "Error: Action '$ACTION' requires a session name"
    exit 1
fi

# Check git repository
check_git_repo

# Get repository information
get_repo_info

# Execute action
case "$ACTION" in
    save)
        save_session "$SESSION_NAME"
        ;;
    list)
        list_sessions
        ;;
    show)
        show_session "$SESSION_NAME"
        ;;
    resume)
        resume_session "$SESSION_NAME"
        ;;
    delete)
        delete_session "$SESSION_NAME"
        ;;
    export)
        export_session "$SESSION_NAME"
        ;;
    clean)
        clean_sessions
        ;;
    *)
        echo "Error: Unknown action: $ACTION"
        usage
        ;;
esac