#!/bin/bash

# Source common configuration
PLUGIN_DIR="$(dirname "$0")"
source "$(dirname "$PLUGIN_DIR")/pomodoro_common.sh"

# Ensure directory exists
ensure_pomo_dir

# Function to update task display
update_task_display() {
    local icon=""
    local label=""
    
    # First check if there's a symlink in current-task directory
    CURRENT_TASK_DIR="$POMO_DIR/current-task"
    if [ -d "$CURRENT_TASK_DIR" ]; then
        # Get the first item in current-task directory
        local task_item=$(ls -1 "$CURRENT_TASK_DIR" 2>/dev/null | head -1)
        
        if [ -n "$task_item" ]; then
            # Extract task name from the symlinked item
            label="$task_item"
            
            # Try to get emoji based on the task name
            local task_lower=$(echo "$label" | tr '[:upper:]' '[:lower:]')
            icon=$(get_emoji_for_keyword "$task_lower")
            
            # If no specific emoji found, use a default
            if [ -z "$icon" ]; then
                icon="📋"
            fi
        fi
    fi
    
    # Fallback to .current_title file if no symlink found
    if [ -z "$label" ]; then
        local current_title=$(get_current_title)
        
        # Extract icon and label from stored task (format: "🎯|Task Name")
        icon=$(echo "$current_title" | cut -d'|' -f1)
        label=$(echo "$current_title" | cut -d'|' -f2-)
        
        # Handle legacy format (space separator) for backward compatibility
        if [ -z "$label" ]; then
            icon=$(echo "$current_title" | awk '{print $1}')
            label=$(echo "$current_title" | cut -d' ' -f2-)
        fi
    fi
    
    # Update display
    sketchybar --set task icon="$icon" \
                         label="$label"
}

# Handle click events
if [ "$SENDER" = "mouse.clicked" ]; then
    # Could add functionality here later (e.g., open task selector)
    :
fi

# Always update display
update_task_display