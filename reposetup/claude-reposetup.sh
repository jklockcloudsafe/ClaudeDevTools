#!/bin/bash
# Property of CloudSafe
# claude-reposetup.sh - Deploy Claude Code optimization files to any repository

set -e

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS] [target_directory]"
    echo ""
    echo "Deploy Claude Code optimization files to target directory"
    echo ""
    echo "Arguments:"
    echo "  target_directory    Directory to optimize (default: current directory)"
    echo ""
    echo "Options:"
    echo "  --replace          Overwrite existing files with fresh templates"
    echo "  --dry-run          Show what would be done without making changes"
    echo "  --install          Install as global 'claude-reposetup' command"
    echo "  -y, --yes          Skip confirmation prompts"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                        # Optimize current directory (skip existing files)"
    echo "  $0 /path/to/project       # Optimize specific directory"
    echo "  $0 --replace              # Replace all existing files with templates"
    echo "  $0 --dry-run ~/project    # Preview changes without applying them"
    echo "  $0 --install              # Install as global command"
    exit 1
}

# Validate directory function
validate_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        echo "Error: Directory '$dir' does not exist"
        exit 1
    fi
    if [[ ! -w "$dir" ]]; then
        echo "Error: Directory '$dir' is not writable"
        exit 1
    fi
}

# Function to create backup of existing file
create_backup() {
    local file="$1"
    local backup_file="${file}.bak.$(date +%Y%m%d_%H%M%S)"
    if [[ "$DRY_RUN" != "true" ]]; then
        cp "$file" "$backup_file"
        echo "  Backup created: $(basename "$backup_file")"
    else
        echo "  Would create backup: $(basename "$backup_file")"
    fi
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
    
    # Copy artifacts directory to ~/bin if it exists
    if [[ -d "$ARTIFACTS_DIR" ]]; then
        echo "Copying artifacts directory..."
        cp -r "$ARTIFACTS_DIR" ~/bin/
        echo "Artifacts copied to ~/bin/artifacts"
    else
        echo "Warning: Artifacts directory not found at $ARTIFACTS_DIR"
    fi
    
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

# Function to confirm replacement
confirm_replacement() {
    if [[ "$SKIP_CONFIRMATIONS" == "true" || "$DRY_RUN" == "true" ]]; then
        return 0
    fi
    
    echo ""
    echo "WARNING: Replace mode will overwrite existing Claude optimization files!"
    echo "Target directory: $TARGET_DIR"
    echo ""
    echo "This will:"
    echo "- Create backups of existing files (.bak files)"
    echo "- Replace them with fresh templates from artifacts"
    echo "- You may lose any customizations you've made"
    echo ""
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        exit 0
    fi
}

# Initialize flags
REPLACE_MODE=false
DRY_RUN=false
SKIP_CONFIRMATIONS=false
TARGET_DIR=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --replace)
            REPLACE_MODE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -y|--yes)
            SKIP_CONFIRMATIONS=true
            shift
            ;;
        --install)
            # Set up variables needed for installation
            SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
            ARTIFACTS_DIR="$SCRIPT_DIR/artifacts"
            install_globally "$(basename "$0")" "claude-reposetup"
            ;;
        -h|--help)
            usage
            ;;
        -*)
            echo "Error: Unknown option $1"
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

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARTIFACTS_DIR="$SCRIPT_DIR/artifacts"

# Determine target directory
if [[ -z "$TARGET_DIR" ]]; then
    TARGET_DIR=$(pwd)
else
    TARGET_DIR=$(realpath "$TARGET_DIR" 2>/dev/null || echo "$TARGET_DIR")
fi

validate_directory "$TARGET_DIR"

PROJECT_NAME=$(basename "$TARGET_DIR")

# Display mode information
if [[ "$DRY_RUN" == "true" ]]; then
    echo "DRY RUN: Previewing Claude Code optimization for $PROJECT_NAME..."
elif [[ "$REPLACE_MODE" == "true" ]]; then
    echo "REPLACE MODE: Deploying Claude Code optimization to $PROJECT_NAME..."
    echo "Warning: This will overwrite existing files with fresh templates."
else
    echo "Deploying Claude Code optimization to $PROJECT_NAME..."
fi

# Validate artifacts directory exists
if [[ ! -d "$ARTIFACTS_DIR" ]]; then
    echo "Error: Artifacts directory not found at $ARTIFACTS_DIR"
    exit 1
fi

# List of required artifact files
ARTIFACT_FILES=(
    ".claude.json"
    ".claudeignore"
    "CLAUDE.md"
    ".claude-rules"
    "PROJECT_CONTEXT.md"
    "request-templates.txt"
    "project-health.sh"
)

# Validate all artifact files exist
echo "Validating artifact files..."
for file in "${ARTIFACT_FILES[@]}"; do
    if [[ ! -f "$ARTIFACTS_DIR/$file" ]]; then
        echo "Error: Required artifact file not found: $ARTIFACTS_DIR/$file"
        exit 1
    fi
done

# Check if we're trying to deploy to the artifacts directory itself
if [[ "$(realpath "$ARTIFACTS_DIR")" == "$(realpath "$TARGET_DIR")" ]]; then
    echo "Target directory is the artifacts directory - skipping file copy."
else
    # Show confirmation if in replace mode
    if [[ "$REPLACE_MODE" == "true" ]]; then
        confirm_replacement
    fi
    
    echo "Processing Claude optimization files..."
    
    files_created=0
    files_skipped=0
    files_replaced=0
    
    for file in "${ARTIFACT_FILES[@]}"; do
        source_file="$ARTIFACTS_DIR/$file"
        target_file="$TARGET_DIR/$file"
        
        if [[ -f "$target_file" ]]; then
            if [[ "$REPLACE_MODE" == "true" ]]; then
                # Replace mode: backup and overwrite
                if [[ "$DRY_RUN" == "true" ]]; then
                    echo "  Would replace $file (with backup)"
                else
                    echo "  Replacing $file..."
                    create_backup "$target_file"
                    cp "$source_file" "$target_file"
                    
                    # Make project-health.sh executable if it was replaced
                    if [[ "$file" == "project-health.sh" ]]; then
                        chmod +x "$target_file"
                    fi
                fi
                ((files_replaced++))
            else
                # Normal mode: skip existing files
                if [[ "$DRY_RUN" == "true" ]]; then
                    echo "  Would skip $file (already exists)"
                else
                    echo "  Skipping $file (already exists)"
                fi
                ((files_skipped++))
            fi
        else
            # File doesn't exist: create it
            if [[ "$DRY_RUN" == "true" ]]; then
                echo "  Would create $file"
            else
                echo "  Creating $file..."
                cp "$source_file" "$target_file"
                
                # Make project-health.sh executable
                if [[ "$file" == "project-health.sh" ]]; then
                    chmod +x "$target_file"
                fi
            fi
            ((files_created++))
        fi
    done
fi

# Update .gitignore with Claude entries
if [[ -f "$TARGET_DIR/.gitignore" ]]; then
    if ! grep -q "# Claude Code" "$TARGET_DIR/.gitignore"; then
        if [[ "$DRY_RUN" == "true" ]]; then
            echo "  Would add Claude Code entries to .gitignore"
        else
            echo "  Adding Claude Code entries to .gitignore"
            echo "" >> "$TARGET_DIR/.gitignore"
            echo "# Claude Code" >> "$TARGET_DIR/.gitignore"
            echo ".claude/" >> "$TARGET_DIR/.gitignore"
            echo "claude-*.log" >> "$TARGET_DIR/.gitignore"
        fi
    else
        echo "  .gitignore already has Claude Code entries"
    fi
else
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "  Would create .gitignore with Claude Code entries"
    else
        echo "  Creating .gitignore with Claude Code entries"
        cat > "$TARGET_DIR/.gitignore" << 'EOF'
# Claude Code
.claude/
claude-*.log

# Dependencies
node_modules/
__pycache__/

# Environment
.env
.env.local

# Build outputs
dist/
build/
*.log

# IDE
.vscode/settings.json
.idea/

# OS
.DS_Store
Thumbs.db
EOF
    fi
fi

echo ""

# Provide appropriate summary based on mode and results
if [[ "$DRY_RUN" == "true" ]]; then
    echo "DRY RUN COMPLETED - No changes were made"
    echo ""
    echo "Summary of what would be done:"
    if [[ ${files_created:-0} -gt 0 ]]; then
        echo "- Files to create: $files_created"
    fi
    if [[ ${files_skipped:-0} -gt 0 ]]; then
        echo "- Files to skip (already exist): $files_skipped"
    fi
    if [[ ${files_replaced:-0} -gt 0 ]]; then
        echo "- Files to replace: $files_replaced"
    fi
    echo ""
    echo "To apply these changes, run the command again without --dry-run"
else
    echo "Claude Code optimization completed successfully!"
    echo ""
    echo "Summary:"
    if [[ ${files_created:-0} -gt 0 ]]; then
        echo "- Files created: $files_created"
    fi
    if [[ ${files_skipped:-0} -gt 0 ]]; then
        echo "- Files skipped (already existed): $files_skipped"
    fi
    if [[ ${files_replaced:-0} -gt 0 ]]; then
        echo "- Files replaced: $files_replaced"
        echo "- Backups created with .bak.YYYYMMDD_HHMMSS extension"
    fi
    echo ""
    echo "Files managed:"
    echo "- .claude.json (project configuration)"
    echo "- .claudeignore (performance optimization)"
    echo "- CLAUDE.md (documentation template)"
    echo "- .claude-rules (automation constraints)"
    echo "- PROJECT_CONTEXT.md (project context template)"
    echo "- request-templates.txt (request templates)"
    echo "- project-health.sh (health check script)"
    echo "- .gitignore (updated with Claude entries)"
    echo ""
    echo "Next steps:"
    echo "- Review and customize template files for your project"
    
    # Suggest running check script with proper path
    check_script_path="$SCRIPT_DIR/claude-repocheck.sh"
    if [[ -f "$check_script_path" ]]; then
        echo "- Run '$check_script_path' to verify the optimization"
    else
        echo "- Run 'claude-repocheck.sh' to verify the optimization"
    fi
    
    if [[ -f "$TARGET_DIR/project-health.sh" ]]; then
        echo "- Run './project-health.sh' to check project health"
    fi
fi