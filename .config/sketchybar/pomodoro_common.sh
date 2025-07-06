#!/bin/bash
# Common configuration and functions for pomodoro system

# Directories and files
POMO_DIR="$HOME/.config/sketchybar/pomodoro"
CONFIG_DIR="$POMO_DIR/config"
TITLE_FILE="$POMO_DIR/.current_title"
WORK_TIME_FILE="$POMO_DIR/.current_work_time"
BREAK_TIME_FILE="$POMO_DIR/.current_break_time"
DEBUG_FILE="$POMO_DIR/.debug_mode"
HISTORY_FILE="$POMO_DIR/.pomodoro_history"
PID_FILE="$POMO_DIR/timer.pid"
MODE_FILE="$POMO_DIR/mode"

# Default values
DEFAULT_WORK_TIME="25"
DEFAULT_BREAK_TIME="5"
DEFAULT_TASK="General Task"
DEFAULT_EMOJI="🍅"

# Function to get emoji for keyword
get_emoji_for_keyword() {
    local task_lower="$1"
    local config_file="$CONFIG_DIR/emoji_mappings.conf"
    
    if [ -f "$config_file" ]; then
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            [[ "$key" =~ ^[[:space:]]*# ]] && continue
            [[ -z "$key" ]] && continue
            
            # Trim whitespace
            key=$(echo "$key" | xargs)
            value=$(echo "$value" | xargs)
            
            if [ "$key" = "default" ]; then
                DEFAULT_EMOJI="$value"
            elif [[ "$task_lower" == *"$key"* ]]; then
                echo "$value"
                return 0
            fi
        done < "$config_file"
    fi
    
    # Return empty if no match
    echo ""
    return 1
}

# Function to get preset by name
get_preset() {
    local preset_name="$1"
    local field="$2"
    local config_file="$CONFIG_DIR/presets.conf"
    
    if [ -f "$config_file" ]; then
        while IFS='|' read -r name work break emoji desc; do
            # Skip comments and empty lines
            [[ "$name" =~ ^[[:space:]]*# ]] && continue
            [[ -z "$name" ]] && continue
            
            # Trim whitespace
            name=$(echo "$name" | xargs)
            
            if [ "$name" = "$preset_name" ]; then
                case "$field" in
                    "work") echo "$work" ;;
                    "break") echo "$break" ;;
                    "emoji") echo "$emoji" ;;
                    "desc") echo "$desc" ;;
                esac
                return 0
            fi
        done < "$config_file"
    fi
    
    return 1
}

# Function to list all presets
list_presets() {
    local config_file="$CONFIG_DIR/presets.conf"
    
    if [ -f "$config_file" ]; then
        while IFS='|' read -r name work break emoji desc; do
            # Skip comments and empty lines
            [[ "$name" =~ ^[[:space:]]*# ]] && continue
            [[ -z "$name" ]] && continue
            
            echo "$name"
        done < "$config_file"
    fi
}

# Notification command
NOTIFY_CMD="/Users/yuvalspiegel/dotfiles/tools/notify-wrapper.sh"

# Create directory if needed
ensure_pomo_dir() {
    mkdir -p "$POMO_DIR"
}

# Get current settings with defaults
get_current_title() {
    if [ -f "$TITLE_FILE" ]; then
        cat "$TITLE_FILE"
    else
        echo "$DEFAULT_TASK"
    fi
}

get_work_minutes() {
    if [ -f "$WORK_TIME_FILE" ]; then
        cat "$WORK_TIME_FILE"
    else
        echo "$DEFAULT_WORK_TIME"
    fi
}

get_break_minutes() {
    if [ -f "$BREAK_TIME_FILE" ]; then
        cat "$BREAK_TIME_FILE"
    else
        echo "$DEFAULT_BREAK_TIME"
    fi
}

# Check debug mode
is_debug_mode() {
    [ -f "$DEBUG_FILE" ]
}

# Function to clean task name (remove emoji if present)
clean_task_name() {
    local task="$1"
    # Check if task starts with an emoji
    local first_chars=$(echo "$task" | cut -c1-4)
    if echo "$first_chars" | LC_ALL=C grep -q '[^\x00-\x7F]'; then
        # Remove emoji and any following spaces
        echo "$task" | sed 's/^[^ ]* *//'
    else
        echo "$task"
    fi
}

# Extract icon from task name
extract_icon() {
    local task="$1"
    # Extract first word which should be the icon
    echo "$task" | awk '{print $1}'
}

# Extract task name without icon
extract_task_name() {
    local task="$1"
    # Remove first word (icon) and return the rest
    echo "$task" | cut -d' ' -f2-
}