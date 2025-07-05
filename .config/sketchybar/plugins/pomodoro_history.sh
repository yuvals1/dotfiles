#!/bin/bash

POMO_DIR="$HOME/.config/sketchybar/pomodoro"
POMO_HISTORY="$POMO_DIR/.pomodoro_history"
RESET_FILE="$POMO_DIR/.reset_time"

# Check if this is a click event
if [ "$SENDER" = "mouse.clicked" ]; then
    # Reset the counter by saving current time
    date '+%Y-%m-%d %H:%M:%S' > "$RESET_FILE"
    sketchybar --set pomodoro_history label="✅ 0"
    exit 0
fi

# Get reset time (if exists)
if [ -f "$RESET_FILE" ]; then
    RESET_TIME=$(cat "$RESET_FILE")
else
    RESET_TIME="1970-01-01 00:00:00"
fi

count=0

if [ -f "$POMO_HISTORY" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        # Extract timestamp from line
        LINE_TIME=$(echo "$line" | cut -d' ' -f1-2)
        
        # Only count work sessions (not breaks) after reset time
        if [[ "$line" != *"[BREAK]"* ]] && [[ "$LINE_TIME" > "$RESET_TIME" ]]; then
            count=$((count + 1))
        fi
    done < "$POMO_HISTORY"
fi

sketchybar --set pomodoro_history label="✅ $count"