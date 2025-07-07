#!/bin/bash

# Source common configuration
PLUGIN_DIR="$(dirname "$0")"
source "$(dirname "$PLUGIN_DIR")/pomodoro_common.sh"

# Ensure directory exists
ensure_pomo_dir

# Function to update task display
update_task_display() {
    local current_title=$(get_current_title)
    
    # Extract icon and label from stored task (format: "🎯|Task Name")
    local icon=$(echo "$current_title" | cut -d'|' -f1)
    local label=$(echo "$current_title" | cut -d'|' -f2-)
    
    # Handle legacy format (space separator) for backward compatibility
    if [ -z "$label" ]; then
        icon=$(echo "$current_title" | awk '{print $1}')
        label=$(echo "$current_title" | cut -d' ' -f2-)
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