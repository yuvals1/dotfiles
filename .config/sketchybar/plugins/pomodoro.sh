#!/bin/bash

POMO_DIR="$HOME/.config/sketchybar/pomodoro"
PID_FILE="$POMO_DIR/timer.pid"
MODE_FILE="$POMO_DIR/mode"

mkdir -p "$POMO_DIR"

# Timer durations
WORK_MINUTES=25
BREAK_MINUTES=5

# Function to stop any running timer
stop_timer() {
    if [ -f "$PID_FILE" ]; then
        kill $(cat "$PID_FILE") 2>/dev/null
        rm -f "$PID_FILE"
    fi
    sketchybar --set pomodoro_work label="🍅" \
               --set pomodoro_break label="☕️"
    rm -f "$MODE_FILE"
}

# Determine which button was clicked
if [ "$NAME" = "work" ]; then
    ITEM="pomodoro_work"
    ICON="🍅"
    DURATION=$WORK_MINUTES
    MODE="work"
else
    ITEM="pomodoro_break"
    ICON="☕️"
    DURATION=$BREAK_MINUTES
    MODE="break"
fi

# Check if this timer is already running
CURRENT_MODE=$(cat "$MODE_FILE" 2>/dev/null)

if [ "$CURRENT_MODE" = "$MODE" ]; then
    # Same button clicked - stop the timer
    stop_timer
    exit 0
fi

# Start new timer (stop any existing timer first)
stop_timer
sleep 0.1  # Small delay to ensure cleanup completes
echo "$MODE" > "$MODE_FILE"

# Run timer in background
(
        # Convert to seconds (handle decimal minutes for testing)
        TIME_LEFT=$(echo "$DURATION * 60" | bc | cut -d. -f1)
        while [ $TIME_LEFT -gt 0 ]; do
            MINUTES=$((TIME_LEFT / 60))
            SECONDS=$((TIME_LEFT % 60))
            TIME_STR=$(printf "%02d:%02d" $MINUTES $SECONDS)
            sketchybar --set "$ITEM" label="$ICON $TIME_STR"
            sleep 1
            TIME_LEFT=$((TIME_LEFT - 1))
        done
        
        # Timer finished
        END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
        
        # Log to history file
        HISTORY_FILE="$POMO_DIR/.pomodoro_history"
        if [ "$MODE" = "work" ]; then
            echo "$END_TIME [WORK] $WORK_MINUTES mins" >> "$HISTORY_FILE"
        else
            echo "$END_TIME [BREAK] $BREAK_MINUTES mins" >> "$HISTORY_FILE"
        fi
        
        # Update history display
        PLUGIN_DIR="$(dirname "$0")"
        sh "$PLUGIN_DIR/pomodoro_history.sh"
        sketchybar --set "$ITEM" label="$ICON"
        rm -f "$PID_FILE" "$MODE_FILE"
) &

# Save PID for stopping later
echo $! > "$PID_FILE"
