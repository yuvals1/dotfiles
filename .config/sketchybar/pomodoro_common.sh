#!/bin/bash
# Common configuration and functions for pomodoro system

# Directories and files
POMO_DIR="$HOME/.config/sketchybar/pomodoro"
CONFIG_DIR="$POMO_DIR/config"
# TITLE_FILE removed - tasks now managed via symlinks
WORK_TIME_FILE="$POMO_DIR/.current_work_time"
BREAK_TIME_FILE="$POMO_DIR/.current_break_time"
DEBUG_FILE="$POMO_DIR/.debug_mode"
HISTORY_FILE="$POMO_DIR/.pomodoro_history"
PID_FILE="$POMO_DIR/timer.pid"
MODE_FILE="$POMO_DIR/mode"
DAILY_GOAL_FILE="$POMO_DIR/.daily_goal"
PAUSE_FILE="$POMO_DIR/.paused"

# Default values
DEFAULT_WORK_TIME="25"
DEFAULT_BREAK_TIME="5"
# Task management removed - now handled via symlinks
DEFAULT_EMOJI="🍅"  # Default emoji for activities
DEFAULT_DAILY_GOAL="8"

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

# Preset functions removed - no longer needed without pomo script

# Notification command
NOTIFY_CMD="/Users/yuvalspiegel/dotfiles/tools/notify-wrapper.sh"

# Create directory if needed
ensure_pomo_dir() {
    mkdir -p "$POMO_DIR"
}

# Task title function removed - now handled via symlinks

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

# Get daily goal
get_daily_goal() {
    if [ -f "$DAILY_GOAL_FILE" ]; then
        cat "$DAILY_GOAL_FILE"
    else
        echo "$DEFAULT_DAILY_GOAL"
    fi
}

# Random emoji function removed - no longer needed

# Function to update idle display for pomodoro buttons
update_idle_display() {
    # Just show a timer emoji when idle
    sketchybar --set pomodoro_timer label="⏲️"
}

# Function removed - tasks now managed via symlinks
