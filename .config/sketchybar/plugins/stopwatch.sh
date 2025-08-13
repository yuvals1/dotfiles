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
        rm -f "$PID_FILE" "$START_FILE"
    fi
    # Reset to mode label and default background/colors
    LABEL=$(get_mode_label)
    sketchybar --set stopwatch label="$LABEL" \
                              background.color="$ITEM_BG_COLOR" \
                              background.drawing=on \
                              label.color="$WHITE" \
                              icon.color="$WHITE"
}

# Check if already running
if [ -f "$PID_FILE" ]; then
    # Stopwatch is running - stop it
    stop_stopwatch
    echo "Stopwatch stopped"
    exit 0
fi

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
                          icon.color="$LABEL_COLOR"

# Run counter in background
(
    START_TIME=$(cat "$START_FILE")
    
    while true; do
        CURRENT_TIME=$(date +%s)
        ELAPSED=$((CURRENT_TIME - START_TIME))
        
        # Format as MM:SS
        MINUTES=$((ELAPSED / 60))
        SECONDS=$((ELAPSED % 60))
        TIME_STR=$(printf "%02d:%02d" $MINUTES $SECONDS)
        
        sketchybar --set stopwatch label="$TIME_STR"
        sleep 1
    done
) &

# Save PID
echo $! > "$PID_FILE"