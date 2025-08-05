#!/bin/bash

# Path to spotify_player
SPOTIFY="/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player"

# Get the current control icons to determine positions
CONTROLS=$(sketchybar --query spotify.menubar_controls | jq -r '.icon.value')

# Count controls to determine click zones
# Each control is roughly 20px wide
if [[ "$CONTROLS" == *"􀊝"* ]] && [[ "$CONTROLS" == *"􀊞"* ]]; then
    # Shuffle + Play/Pause + Repeat (3 controls)
    if [ "$CLICK_X" -lt 20 ]; then
        # Clicked shuffle
        $SPOTIFY playback shuffle
    elif [ "$CLICK_X" -lt 40 ]; then
        # Clicked play/pause
        $SPOTIFY playback play-pause
    else
        # Clicked repeat
        /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_toggle_force_repeat.sh
    fi
elif [[ "$CONTROLS" == *"􀊝"* ]]; then
    # Shuffle + Play/Pause (2 controls)
    if [ "$CLICK_X" -lt 20 ]; then
        # Clicked shuffle
        $SPOTIFY playback shuffle
    else
        # Clicked play/pause
        $SPOTIFY playback play-pause
    fi
else
    # Only Play/Pause (1 control) or fallback
    $SPOTIFY playback play-pause
fi