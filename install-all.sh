#!/bin/bash
# Property of CloudSafe
# install-all.sh - Install all Claude development tools globally

set -e

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Install all Claude development tools as global commands"
    echo ""
    echo "Options:"
    echo "  --update           Update existing installations"
    echo "  --list             List all available tools"
    echo "  --uninstall        Uninstall all Claude tools"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Installed Commands:"
    echo "  claude-reposetup   Setup repository for Claude optimization"
    echo "  claude-repocheck   Check repository Claude optimization status"
    echo "  claude-session     Manage repository-specific Claude sessions"
    echo "  claude-usage       Monitor Claude API usage and costs"
    echo "  claude-optimize    Optimize Claude configuration files"
    echo "  claude-switch      Switch between Pro and API authentication"
    echo ""
    echo "Examples:"
    echo "  $0                 # Install all tools"
    echo "  $0 --update        # Update existing installations"
    echo "  $0 --list          # Show installation status"
    exit 1
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define tools and their locations (bash 3.2 compatible)
TOOL_NAMES=(
    "claude-reposetup"
    "claude-repocheck"
    "claude-session"
    "claude-usage"
    "claude-optimize"
    "claude-switch"
)

TOOL_PATHS=(
    "reposetup/claude-reposetup.sh"
    "reposetup/claude-repocheck.sh"
    "session/claude-session.sh"
    "usage/claude-usage.sh"
    "optimize/claude-optimize.sh"
    "creds/claude-credchange.sh"
)

# Helper function to get tool path by name
get_tool_path() {
    local tool_name="$1"
    local i=0
    for name in "${TOOL_NAMES[@]}"; do
        if [[ "$name" == "$tool_name" ]]; then
            echo "${TOOL_PATHS[$i]}"
            return 0
        fi
        ((i++))
    done
    return 1
}

# Check if tool is installed
is_installed() {
    local tool_name="$1"
    [[ -f ~/bin/$tool_name ]]
}

# Check if tool script exists
tool_exists() {
    local tool_path="$1"
    [[ -f "$SCRIPT_DIR/$tool_path" ]]
}

# Install single tool
install_tool() {
    local tool_name="$1"
    local tool_path="$2"
    local full_path="$SCRIPT_DIR/$tool_path"
    
    if ! tool_exists "$tool_path"; then
        echo "Warning: $tool_name script not found at $tool_path"
        return 1
    fi
    
    echo "Installing $tool_name..."
    if "$full_path" --install >/dev/null 2>&1; then
        echo "  $tool_name installed successfully"
        return 0
    else
        echo "  Failed to install $tool_name"
        return 1
    fi
}

# List installation status
list_tools() {
    echo "Claude Development Tools Status"
    echo "==============================="
    echo ""
    
    local installed_count=0
    local total_count=${#TOOL_NAMES[@]}
    local i=0
    
    for tool_name in "${TOOL_NAMES[@]}"; do
        local tool_path="${TOOL_PATHS[$i]}"
        local status="Not Installed"
        local source_status="Missing"
        
        if tool_exists "$tool_path"; then
            source_status="Available"
        fi
        
        if is_installed "$tool_name"; then
            status="Installed"
            ((installed_count++))
        fi
        
        printf "%-18s %-12s %-12s\n" "$tool_name" "$status" "$source_status"
        ((i++))
    done
    
    echo ""
    echo "Summary: $installed_count/$total_count tools installed"
    
    # Check PATH
    if [[ ":$PATH:" == *":$HOME/bin:"* ]]; then
        echo "PATH: ~/bin is configured"
    else
        echo "PATH: ~/bin not in PATH (restart terminal or run 'source ~/.zshrc')"
    fi
}

# Install all tools
install_all() {
    local update_mode="$1"
    
    echo "Claude Development Tools Installer"
    echo "=================================="
    echo ""
    
    # Check if ~/bin directory exists
    if [[ ! -d ~/bin ]]; then
        echo "Creating ~/bin directory..."
        mkdir -p ~/bin
    fi
    
    local success_count=0
    local total_count=${#TOOL_NAMES[@]}
    local skipped_count=0
    local i=0
    
    for tool_name in "${TOOL_NAMES[@]}"; do
        local tool_path="${TOOL_PATHS[$i]}"
        
        # Skip if already installed and not in update mode
        if [[ "$update_mode" != "true" ]] && is_installed "$tool_name"; then
            echo "Skipping $tool_name (already installed)"
            ((skipped_count++))
            ((i++))
            continue
        fi
        
        if install_tool "$tool_name" "$tool_path"; then
            ((success_count++))
        fi
        ((i++))
    done
    
    echo ""
    echo "Installation Summary"
    echo "==================="
    echo "Successfully installed: $success_count"
    echo "Already installed: $skipped_count"
    echo "Failed: $((total_count - success_count - skipped_count))"
    echo ""
    
    # Check PATH configuration
    if ! grep -q 'export PATH="$HOME/bin:$PATH"' ~/.zshrc 2>/dev/null; then
        echo "Adding ~/bin to PATH in ~/.zshrc..."
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
        echo "PATH configured in ~/.zshrc"
    else
        echo "PATH already configured"
    fi
    
    echo ""
    echo "Installation complete! Available commands:"
    for tool_name in "${TOOL_NAMES[@]}"; do
        if is_installed "$tool_name"; then
            echo "  $tool_name"
        fi
    done
    
    echo ""
    echo "Usage: Run any command with --help for detailed usage information"
    echo "Example: claude-reposetup --help"
    echo ""
    echo "Restart your terminal or run 'source ~/.zshrc' to use the commands immediately"
}

# Uninstall all tools
uninstall_all() {
    echo "Uninstalling Claude development tools..."
    echo ""
    
    local removed_count=0
    
    for tool_name in "${TOOL_NAMES[@]}"; do
        if is_installed "$tool_name"; then
            echo "Removing $tool_name..."
            rm -f ~/bin/$tool_name
            ((removed_count++))
        fi
    done
    
    echo ""
    if [[ $removed_count -eq 0 ]]; then
        echo "No Claude tools were installed"
    else
        echo "Removed $removed_count Claude tools from ~/bin/"
        echo "PATH configuration in ~/.zshrc was left unchanged"
    fi
}

# Parse command line arguments
UPDATE_MODE=false
ACTION="install"

while [[ $# -gt 0 ]]; do
    case $1 in
        --update)
            UPDATE_MODE=true
            shift
            ;;
        --list)
            ACTION="list"
            shift
            ;;
        --uninstall)
            ACTION="uninstall"
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Error: Unknown option: $1"
            usage
            ;;
    esac
done

# Execute action
case "$ACTION" in
    install)
        install_all "$UPDATE_MODE"
        ;;
    list)
        list_tools
        ;;
    uninstall)
        echo "This will remove all Claude development tools from ~/bin/"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            uninstall_all
        else
            echo "Uninstall cancelled"
        fi
        ;;
    *)
        echo "Error: Unknown action: $ACTION"
        usage
        ;;
esac