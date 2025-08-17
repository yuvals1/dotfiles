#!/bin/bash

# Simple stopwatch that counts up
# Stores state in /tmp for simplicity

PID_FILE="/tmp/sketchybar_stopwatch.pid"
START_FILE="/tmp/sketchybar_stopwatch_start"
MODE_FILE="/tmp/sketchybar_stopwatch_mode"
CONFIG_DIR="$HOME/.config/sketchybar"
CONFIG_FILE="$CONFIG_DIR/stopwatch_modes.conf"

# Source colors
source "$CONFIG_DIR/colors.sh"

# Tracking directory
TRACKING_DIR="$HOME/personal/tracking/logs"

# Function to log session to daily file
log_session() {
    local start_epoch="$1"
    local end_epoch="$2"
    local duration="$3"
    
    # Create tracking directory if it doesn't exist
    mkdir -p "$TRACKING_DIR"
    
    # Get date for filename (based on start time)
    local date_str=$(date -r "$start_epoch" '+%Y-%m-%d')
    local log_file="$TRACKING_DIR/${date_str}.log"
    
    # Format timestamps
    local start_time=$(date -r "$start_epoch" '+%H:%M:%S')
    local end_time=$(date -r "$end_epoch" '+%H:%M:%S')
    
    # Format duration (seconds to HH:MM:SS)
    local hours=$((duration / 3600))
    local minutes=$(( (duration % 3600) / 60 ))
    local seconds=$((duration % 60))
    local duration_str=$(printf "%02d:%02d:%02d" $hours $minutes $seconds)
    
    # Get current mode and label
    local mode=$(cat "$MODE_FILE" 2>/dev/null || echo "unknown")
    local label=$(get_mode_label)
    
    # Log entry format: START_TIME | END_TIME | DURATION | MODE | LABEL
    echo "${start_time} | ${end_time} | ${duration_str} | ${mode} | ${label}" >> "$log_file"
}

# Function to get icon for current mode
get_mode_icon() {
    local mode=$(cat "$MODE_FILE" 2>/dev/null || echo "work")
    
    while IFS='|' read -r m icon label color; do
        [[ "$m" =~ ^#.*$ ]] && continue
        [[ -z "$m" ]] && continue
        
        if [[ "$m" == "$mode" ]]; then
            echo "$icon"
            return
        fi
    done < "$CONFIG_FILE"
    
    # Default icon if not found
    echo "⏱️"
}

# Function to get color for current mode
get_mode_color() {
    local mode=$(cat "$MODE_FILE" 2>/dev/null || echo "work")
    
    while IFS='|' read -r m icon label color; do
        [[ "$m" =~ ^#.*$ ]] && continue
        [[ -z "$m" ]] && continue
        
        if [[ "$m" == "$mode" ]]; then
            # Map color names to actual colors
            case "$color" in
                "blue") echo "0xff4a90e2" ;;  # Nice medium blue
                "red") echo "0xffff6b6b" ;;
                "yellow") echo "0xffffeb3b" ;;  # Bright yellow
                "green") echo "$GREEN" ;;
                "purple") echo "0xff9370db" ;;
                "teal") echo "$ACCENT_COLOR" ;;
                "orange") echo "$ORANGE" ;;
                *) echo "$ITEM_BG_COLOR" ;;
            esac
            return
        fi
    done < "$CONFIG_FILE"
    
    echo "$ITEM_BG_COLOR"
}

# Function to get label for current mode
get_mode_label() {
    local mode=$(cat "$MODE_FILE" 2>/dev/null || echo "work")
    
    while IFS='|' read -r m icon label color; do
        [[ "$m" =~ ^#.*$ ]] && continue
        [[ -z "$m" ]] && continue
        
        if [[ "$m" == "$mode" ]]; then
            echo "$label"
            return
        fi
    done < "$CONFIG_FILE"
    
    # Default label if not found
    echo "Ready"
}

# Function to stop the stopwatch
stop_stopwatch() {
    if [ -f "$PID_FILE" ]; then
        kill $(cat "$PID_FILE") 2>/dev/null
        rm -f "$PID_FILE"
    fi
    
    # Log the session if it was running
    if [ -f "$START_FILE" ]; then
        local start_time=$(cat "$START_FILE")
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        # Only log if duration is at least 60 seconds
        if [ $duration -ge 60 ]; then
            log_session "$start_time" "$end_time" "$duration"
        fi
        
        rm -f "$START_FILE"
    fi
    
    # After stopping, hide the stopwatch and render idle mode options
    sketchybar --set stopwatch drawing=off \
                              label="$(get_mode_label)" \
                              background.color="$ITEM_BG_COLOR" \
                              background.drawing=on \
                              label.color="$WHITE" \
                              icon.color="$WHITE"
    bash "$CONFIG_DIR/plugins/render_stopwatch_modes.sh"
}

# Check if already running
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE" 2>/dev/null)
    # Check if the process is actually running
    if [ -n "$OLD_PID" ] && ps -p "$OLD_PID" > /dev/null 2>&1; then
        # Stopwatch is running - stop it
        stop_stopwatch
        echo "Stopwatch stopped"
        exit 0
    else
        # Stale PID file, remove it
        rm -f "$PID_FILE"
    fi
fi

# Also check for any orphaned stopwatch processes and kill them
for pid in $(ps aux | grep -E "bash.*stopwatch\.sh" | grep -v grep | grep -v "$$" | awk '{print $2}'); do
    if [ "$pid" != "$$" ]; then
        echo "Killing orphaned stopwatch process: $pid"
        kill "$pid" 2>/dev/null
    fi
done

# Start new stopwatch
echo "Starting stopwatch"
date +%s > "$START_FILE"

# Set the mode icon and background color
ICON=$(get_mode_icon)
COLOR=$(get_mode_color)
MODE=$(cat "$MODE_FILE" 2>/dev/null || echo "work")

# Check if we need black text for light backgrounds
LABEL_COLOR="$WHITE"
while IFS='|' read -r m icon label color; do
    [[ "$m" =~ ^#.*$ ]] && continue
    [[ -z "$m" ]] && continue
    
    if [[ "$m" == "$MODE" ]] && [[ "$color" == "yellow" ]]; then
        LABEL_COLOR="$BLACK"
        break
    fi
done < "$CONFIG_FILE"

sketchybar --set stopwatch icon="$ICON" \
                          background.color="$COLOR" \
                          background.drawing=on \
                          label.color="$LABEL_COLOR" \
                          icon.color="$LABEL_COLOR" \
                          drawing=on

# Clear idle mode options from center while running
bash "$CONFIG_DIR/plugins/render_stopwatch_modes.sh" clear

# Run counter in background
(
    START_TIME=$(cat "$START_FILE")
    
    while true; do
        CURRENT_TIME=$(date +%s)
        ELAPSED=$((CURRENT_TIME - START_TIME))
        
        # Format as HH:MM:SS
        HOURS=$((ELAPSED / 3600))
        MINUTES=$(( (ELAPSED % 3600) / 60 ))
        SECONDS=$((ELAPSED % 60))
        TIME_STR=$(printf "%02d:%02d:%02d" $HOURS $MINUTES $SECONDS)
        
        # Get the mode label to show with time
        MODE_LABEL=$(get_mode_label)
        
        sketchybar --set stopwatch label="$MODE_LABEL: $TIME_STR"
        sleep 1
    done
) &

# Save PID
echo $! > "$PID_FILE"