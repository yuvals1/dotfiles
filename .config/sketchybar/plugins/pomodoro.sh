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
    # Reset background to normal color
    sketchybar --set "$ITEM" background.color="0xff003547" \
                             background.drawing=on \
                             label.color="0xffffffff"  # White text
    # Show configured times when idle
    update_idle_display
    rm -f "$MODE_FILE" "$PAUSE_FILE"
}

# Determine which button was clicked
if [ "$NAME" = "work" ]; then
    ITEM="pomodoro_timer"
    if is_debug_mode; then
        ICON="🐛"
    else
        ICON="🍅"
    fi
    DURATION=$WORK_MINUTES
    MODE="work"
else
    ITEM="pomodoro_timer"
    if is_debug_mode; then
        ICON="🧪"
    else
        ICON="☕️"
    fi
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

# Remove completed pomodoro indicator when starting new timer
rm -f "$POMO_DIR/.completed_pomodoro"
# Trigger update to hide the completion indicator
sketchybar --trigger pomodoro_update

# Set bright background color when timer starts
if [ "$MODE" = "work" ]; then
    # Bright green for work timer
    TIMER_BG_COLOR="0xff2ecc71"  # Green
    TEXT_COLOR="0xff000000"  # Black text for green background
else
    # Git diff style red for break timer
    TIMER_BG_COLOR="0xffcc3333"  # Git diff red
    TEXT_COLOR="0xffffffff"  # White text for red background
fi

# Apply the bright background
sketchybar --set "$ITEM" background.color="$TIMER_BG_COLOR" \
                         background.drawing=on \
                         label.color="$TEXT_COLOR"

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
        
        # Create completed pomodoro indicator file
        touch "$POMO_DIR/.completed_pomodoro"
        
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
        
        # Reset to show configured time
        # After finish, show both configured times again on the single item
        work_time=$(get_work_minutes)
        break_time=$(get_break_minutes)
        work_display=$(printf "%02d:00" $work_time)
        break_display=$(printf "%02d:00" $break_time)
        work_icon=$(is_debug_mode && echo "🐛" || echo "🍅")
        break_icon=$(is_debug_mode && echo "🧪" || echo "☕️")
        # Reset background to normal color
        sketchybar --set "$ITEM" label="$work_icon ${work_display} · $break_icon ${break_display}" \
                                 background.color="0xff003547" \
                                 background.drawing=on \
                                 label.color="0xffffffff"
        
        rm -f "$PID_FILE" "$MODE_FILE" "$PAUSE_FILE"
) &

# Save PID for stopping later
echo $! > "$PID_FILE"
