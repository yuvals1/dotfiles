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
    # Reset history item backgrounds to normal
    sketchybar --set pomodoro_history background.color="0xff003547" \
                                     background.drawing=on \
                                     label.color="0xffffffff" \
               --set pomodoro_break_history background.color="0xff003547" \
                                           background.drawing=on \
                                           label.color="0xffffffff"
    # Show configured times when idle
    update_idle_display
    rm -f "$MODE_FILE" "$PAUSE_FILE"
}

# Determine which button was clicked
if [ "$NAME" = "work" ]; then
    ITEM="pomodoro_timer"
    ICON="$TIMER_EMOJI"
    DURATION=$WORK_MINUTES
    MODE="work"
else
    ITEM="pomodoro_timer"
    ICON="$TIMER_EMOJI"
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


# Highlight the appropriate history item based on timer mode
if [ "$MODE" = "work" ]; then
    # Highlight work history with light mint background and dark text
    sketchybar --set pomodoro_history background.color="0xff98ff98" \
                                      background.drawing=on \
                                      label.color="0xff003300" \
               --set pomodoro_break_history background.color="0xff003547" \
                                           background.drawing=on \
                                           label.color="0xffffffff"
else
    # Highlight break history with red background
    sketchybar --set pomodoro_break_history background.color="0xffcc3333" \
                                            background.drawing=on \
                                            label.color="0xffffffff" \
               --set pomodoro_history background.color="0xff003547" \
                                     background.drawing=on \
                                     label.color="0xffffffff"
fi

# Run timer in background
(
        # Convert to seconds (handle decimal minutes for testing)
        TIME_LEFT=$(echo "$DURATION * 60" | bc | cut -d. -f1)
        
        while [ $TIME_LEFT -gt 0 ]; do
            MINUTES=$((TIME_LEFT / 60))
            SECONDS=$((TIME_LEFT % 60))
            TIME_STR=$(printf "%02d:%02d" $MINUTES $SECONDS)
            
            # Check if paused
            if [ -f "$PAUSE_FILE" ]; then
                sketchybar --set "$ITEM" label="⏸️ $TIME_STR"
            else
                sketchybar --set "$ITEM" label="$ICON $TIME_STR"
                TIME_LEFT=$((TIME_LEFT - 1))
            fi
            
            sleep 1
        done
        
        # Timer finished
        END_TIME=$(date '+%Y-%m-%d %H:%M')
        
        
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
            # Get current task from symlink
            CURRENT_TASK_DIR="$POMO_DIR/current-task"
            CURRENT_TASK=$(ls -1 "$CURRENT_TASK_DIR" 2>/dev/null | head -1)
            if [ -z "$CURRENT_TASK" ]; then
                CURRENT_TASK="No task"
            fi
            echo "$END_TIME [$CURRENT_TASK] $LOG_MINS mins" >> "$HISTORY_FILE"
            # Send notification
            "$NOTIFY_CMD" "✅ Task Complete" "Finished: $CURRENT_TASK ($LOG_MINS min)"
        else
            echo "$END_TIME [☕️ BREAK] $LOG_MINS mins" >> "$HISTORY_FILE"
            # Send notification
            "$NOTIFY_CMD" "☕️ Break Over" "Ready for next pomodoro?"
        fi
        
        # Trigger history update event
        sketchybar --trigger pomodoro_update
        
        # Reset to show just timer emoji when idle
        sketchybar --set "$ITEM" label="$TIMER_EMOJI"
        
        # Reset history item backgrounds to normal
        sketchybar --set pomodoro_history background.color="0xff003547" \
                                         background.drawing=on \
                                         label.color="0xffffffff" \
                   --set pomodoro_break_history background.color="0xff003547" \
                                               background.drawing=on \
                                               label.color="0xffffffff"
        
        rm -f "$PID_FILE" "$MODE_FILE" "$PAUSE_FILE"
) &

# Save PID for stopping later
echo $! > "$PID_FILE"
