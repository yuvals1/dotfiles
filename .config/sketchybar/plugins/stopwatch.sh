#!/bin/bash

# Simple stopwatch that counts up
# Stores state in /tmp for simplicity

PID_FILE="/tmp/sketchybar_stopwatch.pid"
START_FILE="/tmp/sketchybar_stopwatch_start"

# Function to stop the stopwatch
stop_stopwatch() {
    if [ -f "$PID_FILE" ]; then
        kill $(cat "$PID_FILE") 2>/dev/null
        rm -f "$PID_FILE" "$START_FILE"
    fi
    sketchybar --set stopwatch label="00:00"
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