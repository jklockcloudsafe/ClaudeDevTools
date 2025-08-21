#!/bin/bash
# claudeswitch.sh - Install claude-switch authentication management script (idempotent)

# Create bin directory if it doesn't exist
mkdir -p ~/bin

# Check if claude-switch already exists
if [[ -f ~/bin/claude-switch ]]; then
    echo "✅ claude-switch already installed"
    echo "🔄 Updating claude-switch script..."
else
    echo "📥 Installing claude-switch script..."
fi

# Always update the script to ensure latest version
cat > ~/bin/claude-switch << 'EOF'
#!/bin/bash
# claude-switch - Switch between Pro subscription and API key

set -e

CLAUDE_CONFIG="$HOME/.claude/auth.json"
mkdir -p ~/.claude ~/bin

# Load existing config
if [[ -f "$CLAUDE_CONFIG" ]]; then
    current_mode=$(cat "$CLAUDE_CONFIG" 2>/dev/null | jq -r '.mode' 2>/dev/null || echo 'unknown')
else
    current_mode='unknown'
fi

echo "🔄 Claude Code Authentication Switcher"
echo ""
echo "Current mode: $current_mode"
echo ""
echo "⚠️  Important: Mixing Pro subscription + API key causes auth conflicts!"
echo "   Always use one method at a time."
echo ""
echo "1) 🎯 Pro/Max Subscription (Default - no API charges)"
echo "2) 💳 API Key (Pay-per-use when Pro limit exceeded)"  
echo "3) 📊 Show current status & usage"
echo "4) 🧹 Clear all authentication"
echo "5) ❌ Exit"
echo ""
read -p "Choose option (1-5): " choice

case $choice in
    1)
        echo "🎯 Switching to Pro/Max subscription..."
        
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
        echo "✅ Configured for Pro/Max subscription mode"
        echo "🔑 Run 'claude' and login with your Claude.ai account"
        echo "📊 Monitor usage with /status in Claude or VS Code status bar"
        echo "⚠️  IMPORTANT: Restart your terminal to ensure API key is unset"
        ;;
        
    2)
        echo "💳 Switching to API key mode..."
        
        # Get API key
        if [[ -z "$ANTHROPIC_API_KEY" ]]; then
            echo ""
            echo "📋 Get your API key from: https://console.anthropic.com/account/keys"
            echo ""
            read -p "Enter your Anthropic API key (starts with sk-ant-): " api_key
            
            if [[ ! "$api_key" =~ ^sk-ant- ]]; then
                echo "❌ Invalid API key format. Must start with 'sk-ant-'"
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
        echo "✅ Configured for API key mode"
        echo "💰 Usage will be billed at standard API rates"
        echo "📊 Monitor costs with 'ccusage' command or VS Code extensions"
        echo "⚠️  IMPORTANT: Restart your terminal to load the API key"
        ;;
        
    3)
        echo "📊 Current Authentication Status:"
        echo ""
        
        # Check Claude version
        if command -v claude &> /dev/null; then
            echo "Claude Code version: $(claude --version 2>/dev/null || echo 'Unable to determine')"
        else
            echo "❌ Claude Code not installed"
        fi
        
        echo ""
        echo "Configuration:"
        echo "- Mode: $current_mode"
        echo "- API Key set: $([ -n "$ANTHROPIC_API_KEY" ] && echo 'Yes ⚠️' || echo 'No ✅')"
        echo "- Config file: $([ -f "$CLAUDE_CONFIG" ] && echo 'Present' || echo 'Missing')"
        
        if [[ -n "$ANTHROPIC_API_KEY" && "$current_mode" == "subscription" ]]; then
            echo ""
            echo "⚠️  WARNING: API key is set but mode is subscription!"
            echo "   This causes auth conflicts. Run option 1 to fix."
        fi
        
        echo ""
        echo "📈 Usage Information:"
        if command -v ccusage &> /dev/null; then
            ccusage --summary 2>/dev/null || echo "Run 'ccusage' for detailed usage stats"
        else
            echo "Install 'ccusage' for detailed usage statistics"
        fi
        
        echo ""
        echo "🔍 To check current Claude session status:"
        echo "   Run 'claude' then type '/status'"
        ;;
        
    4)
        echo "🧹 Clearing all authentication..."
        
        # Remove API key
        unset ANTHROPIC_API_KEY
        sed -i '' '/ANTHROPIC_API_KEY/d' ~/.zshrc 2>/dev/null || true
        sed -i '' '/ANTHROPIC_API_KEY/d' ~/.bash_profile 2>/dev/null || true
        
        # Logout Claude session
        echo "/logout" | timeout 10 claude --headless 2>/dev/null || true
        
        # Remove config
        rm -f "$CLAUDE_CONFIG"
        
        echo "✅ All authentication cleared"
        echo "🔄 Restart your terminal and run 'claude-switch' to set up authentication"
        ;;
        
    5)
        echo "👋 Goodbye!"
        exit 0
        ;;
        
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo ""
echo "💡 Tips:"
echo "   - Use Pro subscription for daily work (included in your plan)"
echo "   - Switch to API only when Pro limits are exceeded"  
echo "   - Monitor usage in VS Code status bar to avoid surprises"
echo "   - Run 'claude-switch' anytime to change authentication method"
EOF

# Make script executable
chmod +x ~/bin/claude-switch

# Ensure ~/bin is in PATH (idempotent)
export PATH="$HOME/bin:$PATH"

# Add PATH to ~/.zshrc if not already present
if ! grep -q 'export PATH="$HOME/bin:$PATH"' ~/.zshrc 2>/dev/null; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
    echo "📝 Added ~/bin to PATH in ~/.zshrc"
else
    echo "✅ PATH already configured in ~/.zshrc"
fi

echo "✅ Claude switcher installed and ready!"
echo "📋 Usage: Run 'claude-switch' or 'cs' to manage authentication"
echo "🎯 Recommendation: Start with option 1 (Pro subscription)"