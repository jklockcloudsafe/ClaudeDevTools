#!/bin/bash

set -e

# Find repository root directory
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
CURRENT_DIR=$(pwd)

# Enable tab completion and readline
set +o posix
bind "set completion-ignore-case on" 2>/dev/null || true
bind "set show-all-if-ambiguous on" 2>/dev/null || true

# File completion for @ symbol
_complete_at_files() {
    local cur="${READLINE_LINE:$READLINE_POINT-20:20}"
    local at_pos=$(expr index "$cur" "@")
    
    if [[ $at_pos -gt 0 ]]; then
        local search_term="${cur##*@}"
        local files=()
        
        # Find files from repo root
        while IFS= read -r -d $'\0' file; do
            local rel_path="${file#$REPO_ROOT/}"
            if [[ "$rel_path" == *"$search_term"* ]]; then
                files+=("$rel_path")
            fi
        done < <(find "$REPO_ROOT" -type f -print0 2>/dev/null | head -z -50)
        
        if [[ ${#files[@]} -gt 0 ]]; then
            echo ""
            echo "Available files:"
            printf "%s\n" "${files[@]}" | head -10
            echo -n "Continue typing or press Tab again: "
        fi
    fi
}

# Bind @ completion
bind -x '"\C-i": _complete_at_files'

# Show enhanced header
show_enhanced_header() {
    echo "################################################################################"
    echo "#                    CloudSafe Claude Conversation Tool                       #"
    echo "################################################################################"
    echo "#                                                                              #"
    echo "# Usage: Enter task → specifics → constraints → generates request            #"
    echo "# Tips: Type @filename + Tab for file completion, 'edit' to modify fields    #"
    echo "#                                                                              #"
    echo "################################################################################"
    echo ""
}

# Show last prompt section
show_last_prompt() {
    local last_task="$1"
    local last_specifics="$2"
    local last_constraints="$3"
    
    if [[ -n "$last_task" ]]; then
        echo "Last Prompt:"
        echo "  TASK: $last_task"
        if [[ -n "$last_specifics" ]]; then
            echo "  SPECIFICS: $last_specifics"
        fi
        if [[ -n "$last_constraints" ]]; then
            echo "  CONSTRAINTS: $last_constraints"
        fi
        echo ""
    fi
}

# Highlight @ symbols in text
highlight_at_symbols() {
    local text="$1"
    echo "$text" | sed 's/@\([[:alnum:]._/-]*\)/\x1b[33m@\1\x1b[0m/g'
}


# Persistent preview display
show_preview() {
    local task="$1"
    local specifics="$2"
    local constraints="$3"
    
    echo "PREVIEW:"
    echo "--------"
    echo "FOCUSED REQUEST:"
    if [[ -n "$task" ]]; then
        highlight_at_symbols "TASK: $task"
    else
        echo "TASK: [not set]"
    fi
    if [[ -n "$specifics" ]]; then
        highlight_at_symbols "SPECIFICS: $specifics"
    else
        echo "SPECIFICS: [not set]"
    fi
    if [[ -n "$constraints" ]]; then
        highlight_at_symbols "CONSTRAINTS: $constraints"
    else
        echo "CONSTRAINTS: [not set]"
    fi
    echo "WORKFLOW: Confirm files → List exact changes → Implement → Stop → Ask for next"
    echo "CONFIRM: Use CONFIRMED CHANGES format before implementing"
    echo ""
    echo "=================================================================================="
    echo ""
}


# Initialize variables for edit functionality
prev_request=""
prev_task=""
prev_specifics=""
prev_constraints=""

while true; do
    clear
    show_enhanced_header
    show_last_prompt "$prev_task" "$prev_specifics" "$prev_constraints"
    show_preview "" "" ""
    
    echo "TASK: [$(basename "$CURRENT_DIR")]"
    read -p "> " task_description
    
    # Exit commands
    if [[ "$task_description" == "exit" || "$task_description" == "quit" ]]; then
        break
    fi
    
    # Check for edit previous request
    if [[ "$task_description" == "edit" ]]; then
        echo "Edit which field? (task/specifics/constraints)"
        read -p "> " edit_field
        case "$edit_field" in
            "task") task_description="$prev_task" ;;
            "specifics") 
                task_description="$prev_task"
                clear
                show_enhanced_header
                show_last_prompt "$prev_task" "$prev_specifics" "$prev_constraints"
                show_preview "$task_description" "" ""
                echo "SPECIFICS: [for detailed context]"
                read -p "> " -i "$prev_specifics" specifics
                ;;
            "constraints")
                task_description="$prev_task"
                specifics="$prev_specifics"
                clear
                show_enhanced_header
                show_last_prompt "$prev_task" "$prev_specifics" "$prev_constraints"
                show_preview "$task_description" "$specifics" ""
                echo "CONSTRAINTS:"
                read -p "> " -i "$prev_constraints" additional_constraints
                ;;
        esac
    fi
    
    clear
    show_enhanced_header
    show_last_prompt "$prev_task" "$prev_specifics" "$prev_constraints"
    show_preview "$task_description" "" ""
    
    echo "SPECIFICS: [for detailed context, use @filename for file references]"
    read -p "> " specifics
    
    clear
    show_enhanced_header
    show_last_prompt "$prev_task" "$prev_specifics" "$prev_constraints"
    show_preview "$task_description" "$specifics" ""
    
    echo "CONSTRAINTS:"
    read -p "> " additional_constraints
    
    # Smart constraint filtering
    base_constraints="Do not add features, styling, optimizations, dependencies, error handling, comments, or refactor existing code"
    
    if [[ "$additional_constraints" =~ refactor ]]; then
        base_constraints="${base_constraints/, or refactor existing code/}"
    fi
    if [[ "$additional_constraints" =~ optimize ]]; then
        base_constraints="${base_constraints/optimizations, /}"
    fi
    if [[ "$additional_constraints" =~ style ]]; then
        base_constraints="${base_constraints/styling, /}"
    fi
    if [[ "$additional_constraints" =~ feature ]]; then
        base_constraints="${base_constraints/features, /}"
    fi
    if [[ "$additional_constraints" =~ comment ]]; then
        base_constraints="${base_constraints/comments, /}"
    fi
    if [[ "$additional_constraints" =~ dependenc ]]; then
        base_constraints="${base_constraints/dependencies, /}"
    fi
    
    final_constraints="$base_constraints"
    if [[ -n "$additional_constraints" ]]; then
        final_constraints="$final_constraints, $additional_constraints"
    fi
    
    clear
    show_enhanced_header
    show_last_prompt "$prev_task" "$prev_specifics" "$prev_constraints"
    show_preview "$task_description" "$specifics" "$final_constraints"
    
    request="Follow the rules in $REPO_ROOT/.claude-rules for this task.
Read $REPO_ROOT/PROJECT_CONTEXT.md first.

FOCUSED REQUEST:
TASK: $task_description
SPECIFICS: $specifics
CONSTRAINTS: $final_constraints
WORKFLOW: Confirm files → List exact changes → Implement → Stop → Ask for next
CONFIRM: Use CONFIRMED CHANGES format before implementing"

    # Copy to clipboard
    if command -v pbcopy &> /dev/null; then
        echo "$request" | pbcopy
        echo "✓ Request copied to clipboard!"
    elif command -v xclip &> /dev/null; then
        echo "$request" | xclip -selection clipboard
        echo "✓ Request copied to clipboard!"
    else
        echo "Clipboard not available - copy manually"
    fi
    
    echo ""
    echo "$request"
    echo ""
    echo "Press Enter to continue..."
    read
    
    # Store for next iteration
    prev_task="$task_description"
    prev_specifics="$specifics"
    prev_constraints="$additional_constraints"
done