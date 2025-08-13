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
        # State 0: Pomodoro is visible, do nothing
        ;;
    1)
        # State 1: Spotify is visible
        /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify.sh "$1"
        ;;
    *)
        # Other states: do nothing
        ;;
esac