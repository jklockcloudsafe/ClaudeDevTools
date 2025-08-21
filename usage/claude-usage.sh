#!/bin/bash
# claude-usage.sh - Claude API usage analytics and cost tracking

set -e

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS] [action]"
    echo ""
    echo "Monitor Claude API usage and costs"
    echo ""
    echo "Actions:"
    echo "  summary            Show usage summary (default)"
    echo "  daily              Show daily usage breakdown"
    echo "  weekly             Show weekly usage summary"
    echo "  monthly            Show monthly usage summary"
    echo "  costs              Show estimated costs"
    echo "  status             Show current authentication and rate limit status"
    echo "  export             Export usage data to CSV"
    echo ""
    echo "Options:"
    echo "  --json             Output in JSON format"
    echo "  --period <days>    Analyze last N days (default: 7)"
    echo "  --install          Install as global 'claude-usage' command"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                 # Show weekly usage summary"
    echo "  $0 daily           # Show daily breakdown"
    echo "  $0 costs           # Show cost estimates"
    echo "  $0 --period 30     # Show last 30 days"
    echo "  $0 --json summary  # JSON output for scripts"
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

# Get Claude configuration
get_claude_config() {
    CLAUDE_CONFIG="$HOME/.claude/auth.json"
    if [[ -f "$CLAUDE_CONFIG" ]]; then
        if command -v jq >/dev/null 2>&1; then
            AUTH_MODE=$(jq -r '.mode // "unknown"' "$CLAUDE_CONFIG" 2>/dev/null || echo 'unknown')
        else
            AUTH_MODE='unknown'
        fi
    else
        AUTH_MODE='unknown'
    fi
    
    # Check for API key
    if [[ -n "$ANTHROPIC_API_KEY" ]]; then
        API_KEY_SET="true"
    else
        API_KEY_SET="false"
    fi
}

# Find Claude log files
find_claude_logs() {
    # Common log locations for Claude Code
    LOG_PATHS=(
        "$HOME/.claude/logs"
        "$HOME/.config/claude/logs"
        "/tmp/claude-logs"
        "."
    )
    
    CLAUDE_LOGS=()
    for path in "${LOG_PATHS[@]}"; do
        if [[ -d "$path" ]]; then
            while IFS= read -r -d '' log_file; do
                CLAUDE_LOGS+=("$log_file")
            done < <(find "$path" -name "*.log" -o -name "claude*.log" -print0 2>/dev/null)
        fi
    done
}

# Parse usage from logs
parse_usage_from_logs() {
    local period_days="$1"
    local cutoff_date=$(date -d "$period_days days ago" +%Y-%m-%d 2>/dev/null || date -v-${period_days}d +%Y-%m-%d 2>/dev/null)
    
    # Initialize counters
    TOTAL_REQUESTS=0
    API_REQUESTS=0
    SUBSCRIPTION_REQUESTS=0
    ERROR_COUNT=0
    
    if [[ ${#CLAUDE_LOGS[@]} -eq 0 ]]; then
        echo "Warning: No Claude log files found"
        return
    fi
    
    for log_file in "${CLAUDE_LOGS[@]}"; do
        if [[ -f "$log_file" ]]; then
            # Parse logs for usage patterns (this is a simplified parser)
            # Real implementation would depend on actual Claude log format
            local requests=$(grep -c "request" "$log_file" 2>/dev/null || echo 0)
            local errors=$(grep -c "error\|failed" "$log_file" 2>/dev/null || echo 0)
            
            TOTAL_REQUESTS=$((TOTAL_REQUESTS + requests))
            ERROR_COUNT=$((ERROR_COUNT + errors))
        fi
    done
    
    # Estimate API vs subscription usage based on auth mode
    if [[ "$AUTH_MODE" == "api" ]]; then
        API_REQUESTS=$TOTAL_REQUESTS
    else
        SUBSCRIPTION_REQUESTS=$TOTAL_REQUESTS
    fi
}

# Estimate costs
estimate_costs() {
    # Claude pricing (approximate, as of 2024)
    # These are example rates - actual rates vary by model and tier
    local claude_3_sonnet_input=0.003   # per 1K tokens
    local claude_3_sonnet_output=0.015  # per 1K tokens
    
    # Rough estimation assuming average conversation
    local avg_input_tokens=2000
    local avg_output_tokens=500
    
    local cost_per_request=$(echo "scale=6; ($avg_input_tokens/1000) * $claude_3_sonnet_input + ($avg_output_tokens/1000) * $claude_3_sonnet_output" | bc 2>/dev/null || echo "0.012")
    
    ESTIMATED_COST=$(echo "scale=2; $API_REQUESTS * $cost_per_request" | bc 2>/dev/null || echo "0.00")
}

# Show authentication status
show_auth_status() {
    echo "Authentication Status"
    echo "===================="
    echo "Mode: $AUTH_MODE"
    echo "API Key Set: $API_KEY_SET"
    
    if [[ -f "$CLAUDE_CONFIG" ]]; then
        echo "Config File: Present"
        if command -v jq >/dev/null 2>&1 && [[ -f "$CLAUDE_CONFIG" ]]; then
            local timestamp=$(jq -r '.timestamp // "unknown"' "$CLAUDE_CONFIG" 2>/dev/null || echo "unknown")
            echo "Last Updated: $timestamp"
        fi
    else
        echo "Config File: Missing"
    fi
    
    echo ""
    echo "Rate Limits"
    echo "==========="
    if [[ "$AUTH_MODE" == "api" ]]; then
        echo "Using API key - subject to API rate limits"
        echo "Check https://console.anthropic.com for current limits"
    elif [[ "$AUTH_MODE" == "subscription" ]]; then
        echo "Using Pro subscription - check claude.ai for usage limits"
    else
        echo "Unknown authentication mode"
    fi
}

# Show usage summary
show_summary() {
    local period="$1"
    
    if [[ "$JSON_OUTPUT" == "true" ]]; then
        cat << EOF
{
  "period_days": $period,
  "auth_mode": "$AUTH_MODE",
  "total_requests": $TOTAL_REQUESTS,
  "api_requests": $API_REQUESTS,
  "subscription_requests": $SUBSCRIPTION_REQUESTS,
  "error_count": $ERROR_COUNT,
  "estimated_cost_usd": "$ESTIMATED_COST",
  "log_files_found": ${#CLAUDE_LOGS[@]}
}
EOF
    else
        echo "Claude Usage Summary (Last $period days)"
        echo "========================================"
        echo "Authentication Mode: $AUTH_MODE"
        echo "Total Requests: $TOTAL_REQUESTS"
        echo "API Requests: $API_REQUESTS"
        echo "Subscription Requests: $SUBSCRIPTION_REQUESTS"
        echo "Errors: $ERROR_COUNT"
        
        if [[ $API_REQUESTS -gt 0 ]]; then
            echo "Estimated API Cost: \$$ESTIMATED_COST USD"
        fi
        
        echo "Log Files Analyzed: ${#CLAUDE_LOGS[@]}"
        
        if [[ $ERROR_COUNT -gt 0 ]]; then
            local error_rate=$(echo "scale=1; $ERROR_COUNT * 100 / $TOTAL_REQUESTS" | bc 2>/dev/null || echo "0")
            echo "Error Rate: ${error_rate}%"
        fi
    fi
}

# Export to CSV
export_usage() {
    local export_file="claude_usage_$(date +%Y%m%d_%H%M%S).csv"
    
    echo "Date,Auth_Mode,Total_Requests,API_Requests,Subscription_Requests,Errors,Estimated_Cost" > "$export_file"
    echo "$(date +%Y-%m-%d),$AUTH_MODE,$TOTAL_REQUESTS,$API_REQUESTS,$SUBSCRIPTION_REQUESTS,$ERROR_COUNT,$ESTIMATED_COST" >> "$export_file"
    
    echo "Usage data exported to: $export_file"
}

# Initialize variables
ACTION="summary"
PERIOD_DAYS=7
JSON_OUTPUT=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --install)
            install_globally "$(basename "$0")" "claude-usage"
            ;;
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        --period)
            PERIOD_DAYS="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        summary|daily|weekly|monthly|costs|status|export)
            ACTION="$1"
            shift
            ;;
        *)
            echo "Error: Unknown option: $1"
            usage
            ;;
    esac
done

# Validate period
if ! [[ "$PERIOD_DAYS" =~ ^[0-9]+$ ]] || [[ "$PERIOD_DAYS" -lt 1 ]]; then
    echo "Error: Period must be a positive number"
    exit 1
fi

# Adjust period for different actions
case "$ACTION" in
    daily)
        PERIOD_DAYS=1
        ;;
    weekly)
        PERIOD_DAYS=7
        ;;
    monthly)
        PERIOD_DAYS=30
        ;;
esac

# Get configuration and log data
get_claude_config
find_claude_logs

# Execute action
case "$ACTION" in
    summary|daily|weekly|monthly)
        parse_usage_from_logs "$PERIOD_DAYS"
        estimate_costs
        show_summary "$PERIOD_DAYS"
        ;;
    costs)
        parse_usage_from_logs "$PERIOD_DAYS"
        estimate_costs
        if [[ "$JSON_OUTPUT" == "true" ]]; then
            echo "{\"api_requests\": $API_REQUESTS, \"estimated_cost_usd\": \"$ESTIMATED_COST\"}"
        else
            echo "Cost Estimate (Last $PERIOD_DAYS days)"
            echo "===================================="
            echo "API Requests: $API_REQUESTS"
            echo "Estimated Cost: \$$ESTIMATED_COST USD"
            echo ""
            echo "Note: Costs are estimates based on average token usage"
            echo "Check https://console.anthropic.com for actual billing"
        fi
        ;;
    status)
        show_auth_status
        ;;
    export)
        parse_usage_from_logs "$PERIOD_DAYS"
        estimate_costs
        export_usage
        ;;
    *)
        echo "Error: Unknown action: $ACTION"
        usage
        ;;
esac