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
        
        # Extract icon and clean title for display
        if [ "$MODE" = "work" ]; then
            # Title already contains icon from pomo command (e.g., "🍅 task name")
            # Extract first word (the emoji)
            DISPLAY_ICON=$(echo "$CURRENT_TITLE" | sed 's/^\([^ ]*\).*/\1/')
            # Remove emoji for clean display
            CLEAN_TITLE=$(clean_task_name "$CURRENT_TITLE")
        else
            DISPLAY_ICON="☕️"
        fi
        
        while [ $TIME_LEFT -gt 0 ]; do
            MINUTES=$((TIME_LEFT / 60))
            SECONDS=$((TIME_LEFT % 60))
            TIME_STR=$(printf "%02d:%02d" $MINUTES $SECONDS)
            if [ "$MODE" = "work" ]; then
                sketchybar --set "$ITEM" label="$DISPLAY_ICON $CLEAN_TITLE - $TIME_STR"
            else
                sketchybar --set "$ITEM" label="$DISPLAY_ICON $TIME_STR"
            fi
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
            # Title already contains icon, just log it as is
            echo "$END_TIME [$CURRENT_TITLE] $LOG_MINS mins" >> "$HISTORY_FILE"
        else
            echo "$END_TIME [☕️ BREAK] $LOG_MINS mins" >> "$HISTORY_FILE"
        fi
        
        # Send notification
        if [ "$MODE" = "work" ]; then
            "$NOTIFY_CMD" "✅ Task Complete" "Finished: $CURRENT_TITLE ($LOG_MINS min)"
        else
            "$NOTIFY_CMD" "☕️ Break Over" "Ready for next pomodoro?"
        fi
        
        # Update history display
        sh "$PLUGIN_DIR/pomodoro_history.sh"
        
        # Reset to default icon
        if [ "$MODE" = "work" ]; then
            sketchybar --set "$ITEM" label="🍅"
        else
            sketchybar --set "$ITEM" label="☕️"
        fi
        
        rm -f "$PID_FILE" "$MODE_FILE"
) &

# Save PID for stopping later
echo $! > "$PID_FILE"
