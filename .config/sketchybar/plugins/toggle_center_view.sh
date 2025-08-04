#!/bin/bash

# Toggle between three states:
# State 0: Pomodoro (hide Spotify and YouTube Music)
# State 1: Spotify (hide Pomodoro and YouTube Music)  
# State 2: YouTube Music (hide Pomodoro and Spotify)

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
           --set youtube_music.artwork drawing=off \
           --set youtube_music.anchor drawing=off \
           --set youtube_music.controls drawing=off \
           --set youtube_music.progress drawing=off \
           --set task drawing=off \
           --set pomodoro_work drawing=off \
           --set pomodoro_history drawing=off

# Hide pomodoro break if it exists
if sketchybar --query pomodoro_break &>/dev/null; then
    sketchybar --set pomodoro_break drawing=off
fi

# Show items based on new state
case $NEXT_STATE in
    0)
        # State 0: Show Pomodoro
        sketchybar --set task drawing=on \
                   --set pomodoro_work drawing=on \
                   --set pomodoro_history drawing=on
        
        # Show break button if it exists
        if sketchybar --query pomodoro_break &>/dev/null; then
            sketchybar --set pomodoro_break drawing=on
        fi
        ;;
    1)
        # State 1: Show Spotify
        sketchybar --set spotify.artwork drawing=on \
                   --set spotify.anchor drawing=on \
                   --set spotify.menubar_controls drawing=on \
                   --set spotify.progress drawing=on
        ;;
    2)
        # State 2: Show YouTube Music
        sketchybar --set youtube_music.artwork drawing=on \
                   --set youtube_music.anchor drawing=on \
                   --set youtube_music.controls drawing=on \
                   --set youtube_music.progress drawing=on
        ;;
esac