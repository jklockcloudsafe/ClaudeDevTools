#!/bin/bash
# claude-repocheck.sh - Check for Claude Code optimization files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS] [target_directory]"
    echo ""
    echo "Check for Claude Code optimization files in target directory"
    echo ""
    echo "Arguments:"
    echo "  target_directory    Directory to check (default: current directory)"
    echo ""
    echo "Options:"
    echo "  -v, --verbose      Show detailed validation information"
    echo "  -q, --quiet        Only show summary and errors"
    echo "  --json            Output results in JSON format"
    echo "  --install         Install as global 'claude-repocheck' command"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                       # Check current directory"
    echo "  $0 /path/to/project      # Check specific directory"
    echo "  $0 --verbose ~/project   # Check with detailed output"
    echo "  $0 --json                # Get machine-readable output"
    echo "  $0 --install             # Install as global command"
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

# List of required files (must match claude-reposetup.sh)
REQUIRED_FILES=(
    ".claude.json"
    ".claudeignore"
    "CLAUDE.md"
    ".claude-rules"
    "PROJECT_CONTEXT.md"
    "request-templates.txt"
    "project-health.sh"
)

# Parse command line arguments
VERBOSE=false
QUIET=false
JSON_OUTPUT=false
TARGET_DIR=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        --install)
            install_globally "$(basename "$0")" "claude-repocheck"
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

# Determine target directory
if [[ -z "$TARGET_DIR" ]]; then
    TARGET_DIR=$(pwd)
fi

# Validate target directory
if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: Directory '$TARGET_DIR' does not exist"
    exit 1
fi

TARGET_DIR=$(realpath "$TARGET_DIR")
PROJECT_NAME=$(basename "$TARGET_DIR")

# Initialize counters and results
files_found=0
files_missing=0
files_with_issues=0
total_files=${#REQUIRED_FILES[@]}
results=()

# Logging functions
log_info() {
    if [[ "$QUIET" != "true" && "$JSON_OUTPUT" != "true" ]]; then
        echo -e "${BLUE}[INFO]${NC} $1"
    fi
}

log_ok() {
    if [[ "$QUIET" != "true" && "$JSON_OUTPUT" != "true" ]]; then
        echo -e "${GREEN}[OK]${NC} $1"
    fi
}

log_warning() {
    if [[ "$JSON_OUTPUT" != "true" ]]; then
        echo -e "${YELLOW}[WARNING]${NC} $1"
    fi
}

log_error() {
    if [[ "$JSON_OUTPUT" != "true" ]]; then
        echo -e "${RED}[ERROR]${NC} $1"
    fi
}

log_verbose() {
    if [[ "$VERBOSE" == "true" && "$JSON_OUTPUT" != "true" ]]; then
        echo -e "  ${NC}$1"
    fi
}

# Function to validate JSON syntax
validate_json() {
    local file="$1"
    if command -v jq >/dev/null 2>&1; then
        if jq empty "$file" >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    elif command -v python3 >/dev/null 2>&1; then
        if python3 -m json.tool "$file" >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    else
        # No JSON validator available, assume valid
        return 0
    fi
}

# Function to check if file contains placeholder content
has_placeholders() {
    local file="$1"
    if grep -q "\[.*\]" "$file" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to check individual file
check_file() {
    local filename="$1"
    local filepath="$TARGET_DIR/$filename"
    local status="missing"
    local issues=()
    
    if [[ -f "$filepath" ]]; then
        status="found"
        ((files_found++))
        log_ok "$filename found"
        
        # Additional validation based on file type
        case "$filename" in
            ".claude.json")
                if ! validate_json "$filepath"; then
                    issues+=("invalid JSON syntax")
                    ((files_with_issues++))
                    log_warning "$filename has invalid JSON syntax"
                else
                    log_verbose "JSON syntax is valid"
                fi
                if has_placeholders "$filepath"; then
                    log_verbose "Contains placeholder content - may need customization"
                fi
                ;;
            "project-health.sh")
                if [[ ! -x "$filepath" ]]; then
                    issues+=("not executable")
                    log_verbose "$filename is not executable (may need chmod +x)"
                fi
                ;;
            "CLAUDE.md"|"PROJECT_CONTEXT.md")
                if has_placeholders "$filepath"; then
                    log_verbose "Contains placeholder content - needs customization"
                fi
                ;;
        esac
        
        # Check file size
        local size=$(stat -f%z "$filepath" 2>/dev/null || stat -c%s "$filepath" 2>/dev/null || echo "0")
        if [[ "$size" -eq 0 ]]; then
            issues+=("empty file")
            log_warning "$filename is empty"
        else
            log_verbose "File size: ${size} bytes"
        fi
        
    else
        status="missing"
        ((files_missing++))
        log_error "$filename missing"
    fi
    
    # Store result for JSON output
    if [[ "$JSON_OUTPUT" == "true" ]]; then
        local issues_json="[]"
        if [[ ${#issues[@]} -gt 0 ]]; then
           issues_json="["
           for i in "${!issues[@]}"; do
            issues_json+="\"${issues[$i]//\"/\\\"}\""
            (( i < ${#issues[@]}-1 )) && issues_json+=", "
           done
            issues_json+="]"
            issues_json="${issues_json//, \"\"/, }"
        fi
        results+=("{\"file\":\"$filename\",\"status\":\"$status\",\"issues\":$issues_json}")
    fi
}

# Start the check
if [[ "$JSON_OUTPUT" != "true" ]]; then
    echo "Claude Code Repository Check - $PROJECT_NAME"
    echo "============================================="
    log_info "Checking directory: $TARGET_DIR"
    echo ""
fi

# Check each required file
for file in "${REQUIRED_FILES[@]}"; do
    check_file "$file"
done

# Check .gitignore for Claude entries
gitignore_status="missing"
gitignore_issues=()

if [[ -f "$TARGET_DIR/.gitignore" ]]; then
    if grep -q "# Claude Code" "$TARGET_DIR/.gitignore"; then
        gitignore_status="found"
        log_ok ".gitignore has Claude Code entries"
        log_verbose "Claude Code entries found in .gitignore"
    else
        gitignore_status="found"
        gitignore_issues+=("missing Claude Code entries")
        log_warning ".gitignore missing Claude Code entries"
    fi
else
    gitignore_status="missing"
    log_warning ".gitignore file missing"
fi

# Git repository check
git_status="not_git_repo"
if git -C "$TARGET_DIR" status >/dev/null 2>&1; then
    git_status="git_repo"
    log_ok "Git repository detected"
    uncommitted=$(git -C "$TARGET_DIR" status --porcelain | wc -l)
    if [[ $uncommitted -gt 0 ]]; then
        log_info "$uncommitted uncommitted changes"
        log_verbose "Use 'git status' to see uncommitted changes"
    fi
else
    log_info "Not a git repository"
fi

# Calculate final status
optimization_complete=$((files_found == total_files))
needs_setup=$((files_missing > 0))
has_issues=$((files_with_issues > 0))

# Output results
if [[ "$JSON_OUTPUT" == "true" ]]; then
    # JSON output
    gitignore_issues_json="[]"
    if [[ ${#gitignore_issues[@]} -gt 0 ]]; then
        gitignore_issues_json="["
        for i in "${!gitignore_issues[@]}"; do
            val=${gitignore_issues[$i]}
            gitignore_issues_json+=$(printf '%s' "\"$val\"")
            if (( i < ${#gitignore_issues[@]} - 1 )); then
                gitignore_issues_json+=","
            fi
        done
        gitignore_issues_json+="]"
    fi

    # Build files JSON array
    files_json="[]"
    if [[ ${#results[@]} -gt 0 ]]; then
        files_json="["
        for i in "${!results[@]}"; do
            files_json+="${results[$i]}"
            if (( i < ${#results[@]} - 1 )); then
                files_json+=","
            fi
        done
        files_json+="]"
    fi

    # Pre-calculate recommendation values
    customize_templates_rec="false"
    if has_placeholders "$TARGET_DIR/CLAUDE.md" >/dev/null 2>&1; then
        customize_templates_rec="true"
    fi

    make_executable_rec="false"
    if [[ -f "$TARGET_DIR/project-health.sh" && ! -x "$TARGET_DIR/project-health.sh" ]]; then
        make_executable_rec="true"
    fi

    cat << EOF
{
  "project_name": "$PROJECT_NAME",
  "target_directory": "$TARGET_DIR",
  "summary": {
    "total_files": $total_files,
    "files_found": $files_found,
    "files_missing": $files_missing,
    "files_with_issues": $files_with_issues,
    "optimization_complete": $optimization_complete,
    "needs_setup": $needs_setup
  },
  "files": $files_json,
  "gitignore": {
    "status": "$gitignore_status",
    "issues": $gitignore_issues_json
  },
  "git_repository": "$git_status",
  "recommendations": {
    "run_setup": $needs_setup,
    "customize_templates": $customize_templates_rec,
    "make_executable": $make_executable_rec
  }
}
EOF

else
    # Human readable output
    echo ""
    echo "Summary:"
    echo "========"
    echo "Files found: $files_found/$total_files"

    if [[ $files_with_issues -gt 0 ]]; then
        echo "Files with issues: $files_with_issues"
    fi

    echo ""
    if [[ $optimization_complete -eq 1 ]]; then
        echo -e "${GREEN}Status: Repository is fully optimized for Claude Code${NC}"
        exit 0
    else
        echo -e "${RED}Status: Repository needs Claude Code optimization${NC}"
        echo ""
        echo "Recommendations:"

        # Get script directory to provide proper path to setup script
        check_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        setup_script_path="$check_script_dir/claude-reposetup.sh"

        if [[ -f "$setup_script_path" ]]; then
            echo "- Run '$setup_script_path' to deploy missing files"
            if [[ $files_missing -gt 0 && $files_found -gt 0 ]]; then
                echo "- Use '$setup_script_path' --replace to refresh existing files with latest templates"
            fi
        else
            echo "- Run 'claude-reposetup.sh' to deploy missing files"
        fi

        if [[ -f "$TARGET_DIR/project-health.sh" && ! -x "$TARGET_DIR/project-health.sh" ]]; then
            echo "- Make project-health.sh executable: chmod +x project-health.sh"
        fi

        if has_placeholders "$TARGET_DIR/CLAUDE.md" >/dev/null 2>&1 || \
           has_placeholders "$TARGET_DIR/PROJECT_CONTEXT.md" >/dev/null 2>&1; then
EOF
        fi
        exit 1
fi
fi
