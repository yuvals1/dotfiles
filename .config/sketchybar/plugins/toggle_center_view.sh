#!/bin/bash

# Toggle between three states:
# State 0: Stopwatch
# State 1: History view
# State 2: Spotify

STATE_FILE="$HOME/.config/sketchybar/.center_state"

# Read current state (default to 0 if file doesn't exist)
if [ -f "$STATE_FILE" ]; then
    CURRENT_STATE=$(cat "$STATE_FILE")
else
    CURRENT_STATE=0
fi

# Calculate next state (cycle through 0, 1, 2)
NEXT_STATE=$(( (CURRENT_STATE + 1) % 3 ))

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

# Hide pomodoro break if it exists
if sketchybar --query pomodoro_break &>/dev/null; then
    sketchybar --set pomodoro_break drawing=off
fi

# Show items based on new state
case $NEXT_STATE in
    0)
        # State 0: Show Stopwatch
        sketchybar --set stopwatch drawing=on
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
    2)
        # State 2: Show Spotify
        sketchybar --set spotify.artwork drawing=on \
                   --set spotify.anchor drawing=on \
                   --set spotify.menubar_controls drawing=on \
                   --set spotify.progress drawing=on \
                   --set spotify.context drawing=on
        ;;
esac
