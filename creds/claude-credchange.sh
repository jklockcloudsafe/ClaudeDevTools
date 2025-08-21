#!/bin/bash
# Property of CloudSafe
# claudeswitch.sh - Install claude-switch authentication management script (idempotent)

# Create bin directory if it doesn't exist
mkdir -p ~/bin

# Check if claude-switch already exists
if [[ -f ~/bin/claude-switch ]]; then
    echo "claude-switch already installed"
    echo "Updating claude-switch script..."
else
    echo "Installing claude-switch script..."
fi

# Always update the script to ensure latest version
cat > ~/bin/claude-switch << 'EOF'
#!/bin/bash
# claude-switch - Switch between SSO/Pro subscription and API key

set -e

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Switch between Claude Code authentication modes"
    echo ""
    echo "Options:"
    echo "  --api          Switch to API key mode"
    echo "  --sso          Switch to SSO/Pro subscription mode"
    echo "  --install      Install as global 'claude-switch' command"
    echo "  -h, --help     Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0             # Show current authentication status"
    echo "  $0 --api       # Switch to API key mode"
    echo "  $0 --sso       # Switch to SSO/Pro subscription mode"
    exit 1
}

CLAUDE_CONFIG="$HOME/.claude/auth.json"
mkdir -p ~/.claude ~/bin

# Load existing config
if [[ -f "$CLAUDE_CONFIG" ]]; then
    current_mode=$(cat "$CLAUDE_CONFIG" 2>/dev/null | jq -r '.mode' 2>/dev/null || echo 'unknown')
else
    current_mode='unknown'
fi

# Parse command line arguments
case "${1:-}" in
    --api)
        echo "Switching to API key mode..."
        
        # Get API key
        if [[ -z "$ANTHROPIC_API_KEY" ]]; then
            echo ""
            echo "Get your API key from: https://console.anthropic.com/account/keys"
            echo ""
            read -p "Enter your Anthropic API key (starts with sk-ant-): " api_key
            
            if [[ ! "$api_key" =~ ^sk-ant- ]]; then
                echo "Invalid API key format. Must start with 'sk-ant-'"
                exit 1
            fi
            
            # Add to shell config
            echo "export ANTHROPIC_API_KEY='$api_key'" >> ~/.zshrc
            export ANTHROPIC_API_KEY="$api_key"
        fi
        
        # Logout current session  
        echo "Logging out of current session..."
        echo "/logout" | timeout 10 claude --headless 2>/dev/null || true
        sleep 2
        
        # Save preference
        echo '{"mode": "api", "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' > "$CLAUDE_CONFIG"
        
        echo ""
        echo "Configured for API key mode"
        echo "Usage will be billed at standard API rates"
        echo "Monitor costs with 'claude-usage' command"
        echo "IMPORTANT: Restart your terminal to load the API key"
        ;;
        
    --sso)
        echo "Switching to SSO/Pro subscription mode..."
        
        # Remove API key from environment if set
        if [[ -n "$ANTHROPIC_API_KEY" ]]; then
            echo "Removing API key from environment..."
            unset ANTHROPIC_API_KEY
            
            # Remove from shell config files
            sed -i '' '/ANTHROPIC_API_KEY/d' ~/.zshrc 2>/dev/null || true
            sed -i '' '/ANTHROPIC_API_KEY/d' ~/.bash_profile 2>/dev/null || true
            sed -i '' '/ANTHROPIC_API_KEY/d' ~/.profile 2>/dev/null || true
        fi
        
        # Logout current session
        echo "Logging out of current session..."
        echo "/logout" | timeout 10 claude --headless 2>/dev/null || true
        sleep 2
        
        # Save preference
        echo '{"mode": "subscription", "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' > "$CLAUDE_CONFIG"
        
        echo ""
        echo "Configured for SSO/Pro subscription mode"
        echo "Run 'claude' and login with your Claude.ai account"
        echo "Monitor usage with /status in Claude or VS Code status bar"
        echo "IMPORTANT: Restart your terminal to ensure API key is unset"
        ;;
        
    -h|--help)
        usage
        ;;
        
    --install)
        echo "Installation is handled by install-all.sh"
        exit 0
        ;;
        
    "")
        # Default behavior: show current status
        echo "Claude Code Authentication Status"
        echo "================================"
        echo ""
        
        # Check Claude version
        if command -v claude &> /dev/null; then
            echo "Claude Code version: $(claude --version 2>/dev/null || echo 'Unable to determine')"
        else
            echo "Claude Code not installed"
        fi
        
        echo ""
        echo "Configuration:"
        echo "- Mode: $current_mode"
        echo "- API Key set: $([ -n "$ANTHROPIC_API_KEY" ] && echo 'Yes' || echo 'No')"
        echo "- Config file: $([ -f "$CLAUDE_CONFIG" ] && echo 'Present' || echo 'Missing')"
        
        if [[ -n "$ANTHROPIC_API_KEY" && "$current_mode" == "subscription" ]]; then
            echo ""
            echo "WARNING: API key is set but mode is subscription!"
            echo "   This causes auth conflicts. Run 'claude-switch --sso' to fix."
        fi
        
        echo ""
        echo "To switch authentication:"
        echo "  claude-switch --sso    # Switch to SSO/Pro subscription"
        echo "  claude-switch --api    # Switch to API key mode"
        ;;
        
    *)
        echo "Error: Unknown option: $1"
        usage
        ;;
esac

EOF

# Make script executable
chmod +x ~/bin/claude-switch

# Ensure ~/bin is in PATH (idempotent)
export PATH="$HOME/bin:$PATH"

# Add PATH to ~/.zshrc if not already present
if ! grep -q 'export PATH="$HOME/bin:$PATH"' ~/.zshrc 2>/dev/null; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
    echo "Added ~/bin to PATH in ~/.zshrc"
else
    echo "PATH already configured in ~/.zshrc"
fi

echo "Claude switcher installed and ready!"
echo "Usage: Run 'claude-switch' or 'cs' to manage authentication"
echo "Recommendation: Start with option 1 (Pro subscription)"