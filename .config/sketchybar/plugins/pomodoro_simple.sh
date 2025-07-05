#!/bin/bash

POMO_DIR="$HOME/.config/sketchybar/pomodoro"
PID_FILE="$POMO_DIR/timer.pid"

mkdir -p "$POMO_DIR"

# Function to stop any running timer
stop_timer() {
    if [ -f "$PID_FILE" ]; then
        kill $(cat "$PID_FILE") 2>/dev/null
        rm -f "$PID_FILE"
    fi
    sketchybar --set pomodoro label="🍅"
}

# Check current state
CURRENT_LABEL=$(sketchybar --query pomodoro | jq -r '.label.value')

if [ "$CURRENT_LABEL" = "🍅" ]; then
    # Start timer
    stop_timer  # Clean up any existing timer
    
    # Run timer in background
    (
        TIME_LEFT=$((25 * 60))  # 25 minutes in seconds
        while [ $TIME_LEFT -gt 0 ]; do
            MINUTES=$((TIME_LEFT / 60))
            SECONDS=$((TIME_LEFT % 60))
            TIME_STR=$(printf "%02d:%02d" $MINUTES $SECONDS)
            sketchybar --set pomodoro label="🍅 $TIME_STR"
            sleep 1
            TIME_LEFT=$((TIME_LEFT - 1))
        done
        
        # Timer finished
        sketchybar --set pomodoro label="🍅 Done!"
        sleep 3
        sketchybar --set pomodoro label="🍅"
        rm -f "$PID_FILE"
    ) &
    
    # Save PID for stopping later
    echo $! > "$PID_FILE"
else
    # Stop timer
    stop_timer
fi