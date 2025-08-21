#!/bin/bash
# Property of CloudSafe
# claude-optimize.sh - Optimize Claude configuration files for better performance

set -e

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS] [target_directory]"
    echo ""
    echo "Optimize Claude configuration files for better performance"
    echo ""
    echo "Arguments:"
    echo "  target_directory    Directory to optimize (default: current directory)"
    echo ""
    echo "Options:"
    echo "  --analyze          Show optimization analysis without making changes"
    echo "  --fix              Apply recommended optimizations"
    echo "  --backup           Create backups before making changes"
    echo "  --json             Output analysis in JSON format"
    echo "  --install          Install as global 'claude-optimize' command"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                 # Analyze current directory"
    echo "  $0 --fix           # Apply optimizations to current directory"
    echo "  $0 --analyze /path # Analyze specific directory"
    echo "  $0 --fix --backup  # Apply fixes with backups"
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
    echo "Usage: Run '$target_command' from anywhere"
    echo "Restart your terminal or run 'source ~/.zshrc' to use immediately"
    
    exit 0
}

# Create backup
create_backup() {
    local file="$1"
    local backup_file="${file}.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$file" "$backup_file"
    echo "Backup created: $(basename "$backup_file")"
}

# Analyze .claudeignore file
analyze_claudeignore() {
    local file="$TARGET_DIR/.claudeignore"
    local issues=()
    local suggestions=()
    
    if [[ ! -f "$file" ]]; then
        issues+=("missing")
        suggestions+=("create .claudeignore file")
        CLAUDEIGNORE_ISSUES=("${issues[@]}")
        CLAUDEIGNORE_SUGGESTIONS=("${suggestions[@]}")
        return
    fi
    
    local size=$(wc -l < "$file" 2>/dev/null || echo 0)
    
    # Check for common performance-impacting patterns
    if ! grep -q "node_modules" "$file" 2>/dev/null; then
        issues+=("missing node_modules exclusion")
        suggestions+=("add 'node_modules/' to exclude dependencies")
    fi
    
    if ! grep -q "\.git" "$file" 2>/dev/null; then
        issues+=("missing .git exclusion")
        suggestions+=("add '.git/' to exclude git metadata")
    fi
    
    if ! grep -q "dist\|build" "$file" 2>/dev/null; then
        issues+=("missing build output exclusion")
        suggestions+=("add 'dist/' and 'build/' to exclude build outputs")
    fi
    
    if ! grep -q "\.log" "$file" 2>/dev/null; then
        issues+=("missing log file exclusion")
        suggestions+=("add '*.log' to exclude log files")
    fi
    
    # Check for overly broad patterns
    if grep -q "^\*$" "$file" 2>/dev/null; then
        issues+=("overly broad exclusion")
        suggestions+=("remove '*' pattern - excludes everything")
    fi
    
    # Check file size
    if [[ $size -gt 100 ]]; then
        issues+=("very large .claudeignore")
        suggestions+=("consider consolidating patterns - file has $size lines")
    fi
    
    CLAUDEIGNORE_ISSUES=("${issues[@]}")
    CLAUDEIGNORE_SUGGESTIONS=("${suggestions[@]}")
}

# Analyze .claude.json file
analyze_claude_json() {
    local file="$TARGET_DIR/.claude.json"
    local issues=()
    local suggestions=()
    
    if [[ ! -f "$file" ]]; then
        issues+=("missing")
        suggestions+=("create .claude.json configuration file")
        CLAUDE_JSON_ISSUES=("${issues[@]}")
        CLAUDE_JSON_SUGGESTIONS=("${suggestions[@]}")
        return
    fi
    
    # Validate JSON syntax
    if ! command -v jq >/dev/null 2>&1; then
        issues+=("cannot validate - jq not installed")
    elif ! jq empty "$file" >/dev/null 2>&1; then
        issues+=("invalid JSON syntax")
        suggestions+=("fix JSON syntax errors")
    else
        # Check for performance-related settings
        local max_tokens=$(jq -r '.max_tokens // "none"' "$file" 2>/dev/null)
        if [[ "$max_tokens" == "none" ]]; then
            suggestions+=("consider setting max_tokens for response length control")
        fi
        
        local context_window=$(jq -r '.context_window // "none"' "$file" 2>/dev/null)
        if [[ "$context_window" == "none" ]]; then
            suggestions+=("consider setting context_window for better memory management")
        fi
    fi
    
    CLAUDE_JSON_ISSUES=("${issues[@]}")
    CLAUDE_JSON_SUGGESTIONS=("${suggestions[@]}")
}

# Analyze CLAUDE.md file
analyze_claude_md() {
    local file="$TARGET_DIR/CLAUDE.md"
    local issues=()
    local suggestions=()
    
    if [[ ! -f "$file" ]]; then
        issues+=("missing")
        suggestions+=("create CLAUDE.md documentation file")
        CLAUDE_MD_ISSUES=("${issues[@]}")
        CLAUDE_MD_SUGGESTIONS=("${suggestions[@]}")
        return
    fi
    
    local size=$(wc -c < "$file" 2>/dev/null || echo 0)
    local lines=$(wc -l < "$file" 2>/dev/null || echo 0)
    
    # Check file size
    if [[ $size -gt 50000 ]]; then
        issues+=("very large file")
        suggestions+=("consider splitting into smaller sections - file is $size bytes")
    fi
    
    # Check for placeholder content
    if grep -q "\[.*\]" "$file" 2>/dev/null; then
        issues+=("contains placeholders")
        suggestions+=("customize placeholder content with project-specific information")
    fi
    
    # Check for essential sections
    if ! grep -qi "## project\|# project" "$file" 2>/dev/null; then
        suggestions+=("add project overview section")
    fi
    
    if ! grep -qi "## usage\|# usage" "$file" 2>/dev/null; then
        suggestions+=("add usage instructions section")
    fi
    
    CLAUDE_MD_ISSUES=("${issues[@]}")
    CLAUDE_MD_SUGGESTIONS=("${suggestions[@]}")
}

# Analyze PROJECT_CONTEXT.md file
analyze_project_context() {
    local file="$TARGET_DIR/PROJECT_CONTEXT.md"
    local issues=()
    local suggestions=()
    
    if [[ ! -f "$file" ]]; then
        issues+=("missing")
        suggestions+=("create PROJECT_CONTEXT.md for project state tracking")
        PROJECT_CONTEXT_ISSUES=("${issues[@]}")
        PROJECT_CONTEXT_SUGGESTIONS=("${suggestions[@]}")
        return
    fi
    
    local size=$(wc -c < "$file" 2>/dev/null || echo 0)
    
    # Check if file is mostly empty or placeholder
    if [[ $size -lt 100 ]]; then
        issues+=("nearly empty")
        suggestions+=("add current project context and status")
    fi
    
    # Check for placeholder content
    if grep -q "\[.*\]" "$file" 2>/dev/null; then
        issues+=("contains placeholders")
        suggestions+=("replace placeholders with actual project context")
    fi
    
    PROJECT_CONTEXT_ISSUES=("${issues[@]}")
    PROJECT_CONTEXT_SUGGESTIONS=("${suggestions[@]}")
}

# Generate optimized .claudeignore
generate_claudeignore() {
    local file="$TARGET_DIR/.claudeignore"
    
    cat > "$file" << 'EOF'
# Dependencies
node_modules/
__pycache__/
vendor/
.venv/
env/

# Build outputs
dist/
build/
target/
*.exe
*.dll
*.so
*.dylib

# Logs and temporary files
*.log
*.tmp
*.temp
.DS_Store
Thumbs.db

# Version control
.git/
.svn/
.hg/

# IDE and editor files
.vscode/settings.json
.idea/
*.swp
*.swo
*~

# Environment and secrets
.env
.env.local
.env.production
*.key
*.pem

# Documentation builds
docs/_build/
site/

# Test coverage
coverage/
.coverage
.nyc_output/

# Package manager files
package-lock.json
yarn.lock
Pipfile.lock
EOF
    
    echo "Generated optimized .claudeignore"
}

# Generate optimized .claude.json
generate_claude_json() {
    local file="$TARGET_DIR/.claude.json"
    
    cat > "$file" << 'EOF'
{
  "max_tokens": 4096,
  "context_window": 8192,
  "performance": {
    "exclude_large_files": true,
    "max_file_size": "1MB"
  },
  "preferences": {
    "code_style": "consistent",
    "documentation": "comprehensive"
  }
}
EOF
    
    echo "Generated optimized .claude.json"
}

# Show analysis results
show_analysis() {
    if [[ "$JSON_OUTPUT" == "true" ]]; then
        # JSON output for automation
        cat << EOF
{
  "target_directory": "$TARGET_DIR",
  "claudeignore": {
    "issues": $(printf '%s\n' "${CLAUDEIGNORE_ISSUES[@]}" | jq -R . | jq -s .),
    "suggestions": $(printf '%s\n' "${CLAUDEIGNORE_SUGGESTIONS[@]}" | jq -R . | jq -s .)
  },
  "claude_json": {
    "issues": $(printf '%s\n' "${CLAUDE_JSON_ISSUES[@]}" | jq -R . | jq -s .),
    "suggestions": $(printf '%s\n' "${CLAUDE_JSON_SUGGESTIONS[@]}" | jq -R . | jq -s .)
  },
  "claude_md": {
    "issues": $(printf '%s\n' "${CLAUDE_MD_ISSUES[@]}" | jq -R . | jq -s .),
    "suggestions": $(printf '%s\n' "${CLAUDE_MD_SUGGESTIONS[@]}" | jq -R . | jq -s .)
  },
  "project_context": {
    "issues": $(printf '%s\n' "${PROJECT_CONTEXT_ISSUES[@]}" | jq -R . | jq -s .),
    "suggestions": $(printf '%s\n' "${PROJECT_CONTEXT_SUGGESTIONS[@]}" | jq -R . | jq -s .)
  }
}
EOF
    else
        # Human readable output
        echo "Claude Configuration Analysis: $(basename "$TARGET_DIR")"
        echo "============================================="
        echo ""
        
        echo ".claudeignore Analysis:"
        if [[ ${#CLAUDEIGNORE_ISSUES[@]} -eq 0 ]]; then
            echo "  Status: OK"
        else
            echo "  Issues: ${CLAUDEIGNORE_ISSUES[*]}"
            for suggestion in "${CLAUDEIGNORE_SUGGESTIONS[@]}"; do
                echo "  Suggestion: $suggestion"
            done
        fi
        echo ""
        
        echo ".claude.json Analysis:"
        if [[ ${#CLAUDE_JSON_ISSUES[@]} -eq 0 ]]; then
            echo "  Status: OK"
        else
            echo "  Issues: ${CLAUDE_JSON_ISSUES[*]}"
            for suggestion in "${CLAUDE_JSON_SUGGESTIONS[@]}"; do
                echo "  Suggestion: $suggestion"
            done
        fi
        echo ""
        
        echo "CLAUDE.md Analysis:"
        if [[ ${#CLAUDE_MD_ISSUES[@]} -eq 0 ]]; then
            echo "  Status: OK"
        else
            echo "  Issues: ${CLAUDE_MD_ISSUES[*]}"
            for suggestion in "${CLAUDE_MD_SUGGESTIONS[@]}"; do
                echo "  Suggestion: $suggestion"
            done
        fi
        echo ""
        
        echo "PROJECT_CONTEXT.md Analysis:"
        if [[ ${#PROJECT_CONTEXT_ISSUES[@]} -eq 0 ]]; then
            echo "  Status: OK"
        else
            echo "  Issues: ${PROJECT_CONTEXT_ISSUES[*]}"
            for suggestion in "${PROJECT_CONTEXT_SUGGESTIONS[@]}"; do
                echo "  Suggestion: $suggestion"
            done
        fi
    fi
}

# Apply fixes
apply_fixes() {
    local fixes_applied=0
    
    echo "Applying Claude configuration optimizations..."
    echo ""
    
    # Fix .claudeignore
    if [[ " ${CLAUDEIGNORE_ISSUES[*]} " == *"missing"* ]] || [[ ${#CLAUDEIGNORE_SUGGESTIONS[@]} -gt 0 ]]; then
        if [[ "$CREATE_BACKUPS" == "true" && -f "$TARGET_DIR/.claudeignore" ]]; then
            create_backup "$TARGET_DIR/.claudeignore"
        fi
        generate_claudeignore
        ((fixes_applied++))
    fi
    
    # Fix .claude.json
    if [[ " ${CLAUDE_JSON_ISSUES[*]} " == *"missing"* ]]; then
        if [[ "$CREATE_BACKUPS" == "true" && -f "$TARGET_DIR/.claude.json" ]]; then
            create_backup "$TARGET_DIR/.claude.json"
        fi
        generate_claude_json
        ((fixes_applied++))
    fi
    
    echo ""
    if [[ $fixes_applied -eq 0 ]]; then
        echo "No automatic fixes available. Manual review recommended."
    else
        echo "Applied $fixes_applied optimization(s)."
        echo "Run 'claude-optimize --analyze' to verify improvements."
    fi
}

# Parse command line arguments
MODE="analyze"
TARGET_DIR=""
JSON_OUTPUT=false
CREATE_BACKUPS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --install)
            install_globally "$(basename "$0")" "claude-optimize"
            ;;
        --analyze)
            MODE="analyze"
            shift
            ;;
        --fix)
            MODE="fix"
            shift
            ;;
        --backup)
            CREATE_BACKUPS=true
            shift
            ;;
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            if [[ -z "$TARGET_DIR" ]]; then
                TARGET_DIR="$1"
            else
                echo "Error: Multiple directories specified"
                usage
            fi
            shift
            ;;
    esac
done

# Determine target directory
if [[ -z "$TARGET_DIR" ]]; then
    TARGET_DIR=$(pwd)
else
    TARGET_DIR=$(realpath "$TARGET_DIR" 2>/dev/null || echo "$TARGET_DIR")
fi

# Validate target directory
if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: Directory '$TARGET_DIR' does not exist"
    exit 1
fi

# Initialize arrays
CLAUDEIGNORE_ISSUES=()
CLAUDEIGNORE_SUGGESTIONS=()
CLAUDE_JSON_ISSUES=()
CLAUDE_JSON_SUGGESTIONS=()
CLAUDE_MD_ISSUES=()
CLAUDE_MD_SUGGESTIONS=()
PROJECT_CONTEXT_ISSUES=()
PROJECT_CONTEXT_SUGGESTIONS=()

# Run analysis
analyze_claudeignore
analyze_claude_json
analyze_claude_md
analyze_project_context

# Execute mode
case "$MODE" in
    analyze)
        show_analysis
        ;;
    fix)
        apply_fixes
        ;;
    *)
        echo "Error: Unknown mode: $MODE"
        usage
        ;;
esac