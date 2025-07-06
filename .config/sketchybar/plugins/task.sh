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
    local needs_save=false
    
    # Check if title already has an emoji (from pomo command)
    # Get the first "word" and check if it contains non-ASCII characters
    local first_word=$(echo "$current_title" | awk '{print $1}')
    if echo "$first_word" | LC_ALL=C grep -q '[^[:print:][:space:]]'; then
        # Title has emoji, extract it
        local icon=$(extract_icon "$current_title")
        local clean_title=$(extract_task_name "$current_title")
    else
        # No emoji in title, try to find one based on keywords
        local task_lower=$(echo "$current_title" | tr '[:upper:]' '[:lower:]')
        local icon=$(get_emoji_for_keyword "$task_lower")
        
        if [ -z "$icon" ]; then
            # No keyword match, use random emoji
            icon=$(get_random_emoji)
        fi
        local clean_title="$current_title"
        needs_save=true
    fi
    
    # Save the emoji-enhanced title back to file if we added an emoji
    if [ "$needs_save" = true ]; then
        echo "$icon $clean_title" > "$TITLE_FILE"
    fi
    
    # Update display
    sketchybar --set task icon="$icon" \
                         label="$clean_title"
}

# Handle click events
if [ "$SENDER" = "mouse.clicked" ]; then
    # Could add functionality here later (e.g., open task selector)
    :
fi

# Always update display
update_task_display