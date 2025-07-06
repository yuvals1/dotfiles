#!/bin/bash

# Source common configuration
PLUGIN_DIR="$(dirname "$0")"
source "$(dirname "$PLUGIN_DIR")/pomodoro_common.sh"

# Ensure directory exists
ensure_pomo_dir

# Function to get random emoji
get_random_emoji() {
    # Array of fun emojis to use as defaults
    local emojis=(
        "🎯" "💡" "🚀" "⭐" "🎨" "🔧" "📝" "🎪" "🎭" "🎸"
        "🌟" "💫" "✨" "🔥" "💎" "🎯" "🎲" "🎮" "🎨" "🎬"
        "🏆" "🎯" "🌈" "🦄" "🐉" "🦋" "🌺" "🌸" "🍄" "🌻"
    )
    local random_index=$((RANDOM % ${#emojis[@]}))
    echo "${emojis[$random_index]}"
}

# Function to update task display
update_task_display() {
    local current_title=$(get_current_title)
    
    # Always treat title as plain text and find emoji based on keywords
    local task_lower=$(echo "$current_title" | tr '[:upper:]' '[:lower:]')
    local icon=$(get_emoji_for_keyword "$task_lower")
    
    if [ -z "$icon" ]; then
        # No keyword match, use random emoji
        icon=$(get_random_emoji)
    fi
    
    # Update display
    sketchybar --set task icon="$icon" \
                         label="$current_title"
}

# Handle click events
if [ "$SENDER" = "mouse.clicked" ]; then
    # Could add functionality here later (e.g., open task selector)
    :
fi

# Always update display
update_task_display