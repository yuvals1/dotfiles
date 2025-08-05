#!/bin/bash

# Dispatcher script that routes keyboard commands to the correct music service
# based on which one is currently visible

# Check current state
STATE_FILE="$HOME/.config/sketchybar/.center_state"
if [ -f "$STATE_FILE" ]; then
    CURRENT_STATE=$(cat "$STATE_FILE")
else
    CURRENT_STATE=0
fi

# Route to appropriate service based on state
case $CURRENT_STATE in
    0)
        # State 0: Spotify is visible
        /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify.sh "$1"
        ;;
    1)
        # State 1: YouTube Music is visible
        /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/youtube_music_keyboard.sh "$1"
        ;;
    *)
        # State 2 or other: Pomodoro is visible, do nothing
        ;;
esac