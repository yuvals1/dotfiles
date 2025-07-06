#!/bin/bash

POMO_DIR="$HOME/.config/sketchybar/pomodoro"
PID_FILE="$POMO_DIR/timer.pid"
MODE_FILE="$POMO_DIR/mode"
TITLE_FILE="$POMO_DIR/.current_title"
WORK_TIME_FILE="$POMO_DIR/.current_work_time"
BREAK_TIME_FILE="$POMO_DIR/.current_break_time"
DEBUG_FILE="$POMO_DIR/.debug_mode"

mkdir -p "$POMO_DIR"

# Function to get smart icon based on task name
get_task_icon() {
    local task="$1"
    
    # Check if task already starts with an emoji
    local first_chars=$(echo "$task" | cut -c1-4)
    if echo "$first_chars" | LC_ALL=C grep -q '[^\x00-\x7F]'; then
        # Task likely starts with an emoji, return it
        echo "$task" | sed 's/^\([^ ]*\).*/\1/'
        return
    fi
    
    # Otherwise use keyword mapping
    local task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$task_lower" == *"break"* ]]; then
        echo "☕️"
    elif [[ "$task_lower" == *"technion"* ]]; then
        echo "🎓"
    elif [[ "$task_lower" == *"logistics"* ]]; then
        echo "📦"
    elif [[ "$task_lower" == *"dotfiles"* ]]; then
        echo "⚙️"
    elif [[ "$task_lower" == *"therapy"* ]]; then
        echo "🧘"
    else
        echo "🍅"  # Default
    fi
}

# Function to clean task name (remove emoji if present)
clean_task_name() {
    local task="$1"
    # Check if task starts with an emoji
    local first_chars=$(echo "$task" | cut -c1-4)
    if echo "$first_chars" | LC_ALL=C grep -q '[^\x00-\x7F]'; then
        # Remove emoji and any following spaces
        echo "$task" | sed 's/^[^ ]* *//'
    else
        echo "$task"
    fi
}

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

# Timer durations
if [ -f "$DEBUG_FILE" ]; then
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
        if [ -f "$DEBUG_FILE" ]; then
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
            ICON=$(get_task_icon "$CURRENT_TITLE")
            CLEAN_TITLE=$(clean_task_name "$CURRENT_TITLE")
            echo "$END_TIME [$ICON $CLEAN_TITLE] $LOG_MINS mins" >> "$HISTORY_FILE"
        else
            echo "$END_TIME [☕️ BREAK] $LOG_MINS mins" >> "$HISTORY_FILE"
        fi
        
        # Send notification
        NOTIFY_CMD="/Users/yuvalspiegel/dotfiles/tools/notify-wrapper.sh"
        if [ "$MODE" = "work" ]; then
            "$NOTIFY_CMD" "✅ Task Complete" "Finished: $CURRENT_TITLE ($LOG_MINS min)"
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
