#!/bin/bash

# Toggle between two states:
# State 0: Stopwatch
# State 1: History view

STATE_FILE="$HOME/.config/sketchybar/.center_state"

# Read current state (default to 0 if file doesn't exist)
if [ -f "$STATE_FILE" ]; then
    CURRENT_STATE=$(cat "$STATE_FILE")
else
    CURRENT_STATE=0
fi

# Calculate next state (cycle through 0, 1)
NEXT_STATE=$(( (CURRENT_STATE + 1) % 2 ))

# Save new state
echo "$NEXT_STATE" > "$STATE_FILE"

# Hide all center items first
sketchybar --set spotify.artwork drawing=off \
           --set spotify.anchor drawing=off \
           --set spotify.menubar_controls drawing=off \
           --set spotify.progress drawing=off \
           --set spotify.context drawing=off \
           --set youtube_music.artwork drawing=off \
           --set youtube_music.anchor drawing=off \
           --set youtube_music.controls drawing=off \
           --set youtube_music.progress drawing=off \
           --set stopwatch drawing=off \
           --set stopwatch_icon drawing=off \
           --set stopwatch_history drawing=off \
           --set task drawing=off \
           --set pomodoro_timer drawing=off \
           --set pomodoro_history drawing=off \
           --set pomodoro_break_history drawing=off

# Also hide dynamic history items
for i in {0..9}; do
    sketchybar --set history_mode_$i drawing=off 2>/dev/null
done
sketchybar --set history_date drawing=off 2>/dev/null

# Also hide dynamic mode option items (idle stopwatch view)
for i in {0..30}; do
    sketchybar --set mode_option_$i drawing=off 2>/dev/null
done

# Hide pomodoro break if it exists
if sketchybar --query pomodoro_break &>/dev/null; then
    sketchybar --set pomodoro_break drawing=off
fi

# Show items based on new state
case $NEXT_STATE in
    0)
        # State 0: Stopwatch view - always show timer icon
        sketchybar --set stopwatch_icon drawing=on
        
        PID_FILE="/tmp/sketchybar_stopwatch.pid"
        if [ -f "$PID_FILE" ]; then
            # If running, show the stopwatch timer item
            sketchybar --set stopwatch drawing=on
        else
            # If idle, show the selectable mode options without re-rendering if they exist
            sketchybar --set stopwatch drawing=off
            if sketchybar --query mode_option_0 &>/dev/null; then
                for i in {0..30}; do
                    sketchybar --set mode_option_$i drawing=on 2>/dev/null
                done
            else
                bash "$HOME/.config/sketchybar/plugins/stopwatch.sh render_modes"
            fi
        fi
        ;;
    1)
        # State 1: Show History
        # Trigger update to create and show history items
        bash "$HOME/.config/sketchybar/plugins/stopwatch_history.sh"
        # Show the dynamically created items
        sketchybar --set history_date drawing=on 2>/dev/null
        for i in {0..9}; do
            sketchybar --set history_mode_$i drawing=on 2>/dev/null
        done
        ;;
esac
