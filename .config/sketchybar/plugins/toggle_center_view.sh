#!/bin/bash

# Toggle between three states:
# State 0: Spotify (hide YouTube Music and Pomodoro)
# State 1: YouTube Music (hide Spotify and Pomodoro)
# State 2: Pomodoro (hide Spotify and YouTube Music)

STATE_FILE="$HOME/.config/sketchybar/.center_state"

# Read current state (default to 0 if file doesn't exist)
if [ -f "$STATE_FILE" ]; then
    CURRENT_STATE=$(cat "$STATE_FILE")
else
    CURRENT_STATE=0
fi

# Calculate next state (cycle through 0, 1, 2)
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
           --set task drawing=off \
           --set pomodoro_timer drawing=off \
           --set pomodoro_history drawing=off \
           --set pomodoro_break_history drawing=off

# Hide pomodoro break if it exists
if sketchybar --query pomodoro_break &>/dev/null; then
    sketchybar --set pomodoro_break drawing=off
fi

# Show items based on new state
case $NEXT_STATE in
    0)
        # State 0: Show Spotify
        sketchybar --set spotify.artwork drawing=on \
                   --set spotify.anchor drawing=on \
                   --set spotify.menubar_controls drawing=on \
                   --set spotify.progress drawing=on \
                   --set spotify.context drawing=on
        ;;
    1)
    #     # State 1: Show YouTube Music
    #     sketchybar --set youtube_music.artwork drawing=on \
    #                --set youtube_music.anchor drawing=on \
    #                --set youtube_music.controls drawing=on \
    #                --set youtube_music.progress drawing=on
    #     ;;
    # 2)
        # State 2: Show Pomodoro
        sketchybar --set task drawing=on \
                   --set pomodoro_timer drawing=on \
                   --set pomodoro_history drawing=on \
                   --set pomodoro_break_history drawing=on
        
        # Show break button if it exists
        # No separate break button anymore
        ;;
esac
