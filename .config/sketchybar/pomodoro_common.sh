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
DEFAULT_EMOJI="🍅"  # Used for display purposes in pomo --emoji

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

# Get recent unique tasks from history
get_recent_tasks() {
    local limit="${1:-5}"  # Default to 5 recent tasks
    
    if [ -f "$HISTORY_FILE" ]; then
        # Extract tasks from history, remove duplicates, get most recent
        # First get all unique tasks, then get the last N and reverse
        awk -F'[][]' '{print $2}' "$HISTORY_FILE" | \
        sed 's/^ *//;s/ *$//' | \
        grep -v "BREAK" | \
        grep -v "^[[:space:]]*$" | \
        awk '!seen[$0]++ {tasks[NR]=$0} END {start=NR-'"$((limit-1))"'; if(start<1)start=1; for(i=NR;i>=start;i--) if(tasks[i]) print tasks[i]}'
    fi
}