#!/bin/bash

# Source common configuration
PLUGIN_DIR="$(dirname "$0")"
source "$(dirname "$PLUGIN_DIR")/pomodoro_common.sh"

# Ensure directory exists
ensure_pomo_dir



# Timer durations
if is_debug_mode; then
    # Debug mode: 1 second timers
    WORK_MINUTES=0.03
    BREAK_MINUTES=0.03
else
    # Normal mode
    WORK_MINUTES=$(get_work_minutes)
    BREAK_MINUTES=$(get_break_minutes)
fi

# Function to stop any running timer
stop_timer() {
    if [ -f "$PID_FILE" ]; then
        kill $(cat "$PID_FILE") 2>/dev/null
        rm -f "$PID_FILE"
    fi
    # Show configured times when idle
    local work_time=$(get_work_minutes)
    local break_time=$(get_break_minutes)
    sketchybar --set pomodoro_work label="🍅 ${work_time}" \
               --set pomodoro_break label="☕️ ${break_time}"
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
        if is_debug_mode; then
            # Debug mode: always log 60 minutes
            LOG_MINS=60
        else
            # Normal mode: log actual minutes
            if [ "$MODE" = "work" ]; then
                LOG_MINS=$(get_work_minutes)
            else
                LOG_MINS=$(get_break_minutes)
            fi
        fi
        
        if [ "$MODE" = "work" ]; then
            # Get current title from file for logging
            CURRENT_TITLE=$(get_current_title)
            echo "$END_TIME [$CURRENT_TITLE] $LOG_MINS mins" >> "$HISTORY_FILE"
            # Send notification
            "$NOTIFY_CMD" "✅ Task Complete" "Finished: $CURRENT_TITLE ($LOG_MINS min)"
        else
            echo "$END_TIME [☕️ BREAK] $LOG_MINS mins" >> "$HISTORY_FILE"
            # Send notification
            "$NOTIFY_CMD" "☕️ Break Over" "Ready for next pomodoro?"
        fi
        
        # Update history display
        sh "$PLUGIN_DIR/pomodoro_history.sh"
        
        # Reset to show configured time
        if [ "$MODE" = "work" ]; then
            idle_time=$(get_work_minutes)
        else
            idle_time=$(get_break_minutes)
        fi
        sketchybar --set "$ITEM" label="$ICON ${idle_time}"
        
        rm -f "$PID_FILE" "$MODE_FILE"
) &

# Save PID for stopping later
echo $! > "$PID_FILE"
