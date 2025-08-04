#!/bin/bash

# Toggle between music and pomodoro views in center

# Check if spotify items are currently visible
SPOTIFY_VISIBLE=$(sketchybar --query spotify.anchor | jq -r '.geometry.drawing')

if [ "$SPOTIFY_VISIBLE" = "on" ]; then
    # Hide music items, show pomodoro items
    sketchybar --set spotify.artwork drawing=off \
               --set spotify.anchor drawing=off \
               --set spotify.menubar_controls drawing=off \
               --set spotify.progress drawing=off \
               --set task drawing=on \
               --set pomodoro_work drawing=on \
               --set pomodoro_history drawing=on
    
    # Also check if break button exists (it might be commented out)
    if sketchybar --query pomodoro_break &>/dev/null; then
        sketchybar --set pomodoro_break drawing=on
    fi
else
    # Hide pomodoro items, show music items
    sketchybar --set task drawing=off \
               --set pomodoro_work drawing=off \
               --set pomodoro_history drawing=off \
               --set spotify.artwork drawing=on \
               --set spotify.anchor drawing=on \
               --set spotify.menubar_controls drawing=on \
               --set spotify.progress drawing=on
    
    # Also hide break button if it exists
    if sketchybar --query pomodoro_break &>/dev/null; then
        sketchybar --set pomodoro_break drawing=off
    fi
fi