#!/bin/bash

POMO_DIR="$HOME/.config/sketchybar/pomodoro"
PID_FILE="$POMO_DIR/timer.pid"
MODE_FILE="$POMO_DIR/mode"
TITLE_FILE="$POMO_DIR/.current_title"
WORK_TIME_FILE="$POMO_DIR/.current_work_time"
BREAK_TIME_FILE="$POMO_DIR/.current_break_time"
MULTIPLIER_FILE="$POMO_DIR/.time_multiplier"

mkdir -p "$POMO_DIR"

# Function to get current title
get_current_title() {
    if [ -f "$TITLE_FILE" ]; then
        cat "$TITLE_FILE"
    else
        echo "General Task"
    fi
}

# Function to get timer durations
get_work_minutes() {
    if [ -f "$WORK_TIME_FILE" ]; then
        cat "$WORK_TIME_FILE"
    else
        echo "25"
    fi
}

get_break_minutes() {
    if [ -f "$BREAK_TIME_FILE" ]; then
        cat "$BREAK_TIME_FILE"
    else
        echo "5"
    fi
}

# Get time multiplier (default to 1 for normal speed)
get_time_multiplier() {
    if [ -f "$MULTIPLIER_FILE" ]; then
        cat "$MULTIPLIER_FILE"
    else
        echo "1"
    fi
}

# Timer durations with multiplier applied
MULTIPLIER=$(get_time_multiplier)
WORK_MINUTES=$(echo "$(get_work_minutes) * $MULTIPLIER" | bc -l)
BREAK_MINUTES=$(echo "$(get_break_minutes) * $MULTIPLIER" | bc -l)

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
        CURRENT_TITLE=$(get_current_title)
        while [ $TIME_LEFT -gt 0 ]; do
            MINUTES=$((TIME_LEFT / 60))
            SECONDS=$((TIME_LEFT % 60))
            TIME_STR=$(printf "%02d:%02d" $MINUTES $SECONDS)
            if [ "$MODE" = "work" ]; then
                sketchybar --set "$ITEM" label="$ICON $TIME_STR - $CURRENT_TITLE"
            else
                sketchybar --set "$ITEM" label="$ICON $TIME_STR"
            fi
            sleep 1
            TIME_LEFT=$((TIME_LEFT - 1))
        done
        
        # Timer finished
        END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
        
        # Log to history file
        HISTORY_FILE="$POMO_DIR/.pomodoro_history"
        if [ "$MODE" = "work" ]; then
            ACTUAL_MINS=$(get_work_minutes)
            echo "$END_TIME [$CURRENT_TITLE] $ACTUAL_MINS mins" >> "$HISTORY_FILE"
        else
            ACTUAL_MINS=$(get_break_minutes)
            echo "$END_TIME [BREAK] $ACTUAL_MINS mins" >> "$HISTORY_FILE"
        fi
        
        # Send notification
        NOTIFY_CMD="/Users/yuvalspiegel/dotfiles/tools/notify-wrapper.sh"
        if [ "$MODE" = "work" ]; then
            "$NOTIFY_CMD" "✅ Task Complete" "Finished: $CURRENT_TITLE ($ACTUAL_MINS min)"
        else
            "$NOTIFY_CMD" "☕️ Break Over" "Ready for next pomodoro?"
        fi
        
        # Update history display
        PLUGIN_DIR="$(dirname "$0")"
        sh "$PLUGIN_DIR/pomodoro_history.sh"
        sketchybar --set "$ITEM" label="$ICON"
        rm -f "$PID_FILE" "$MODE_FILE"
) &

# Save PID for stopping later
echo $! > "$PID_FILE"
