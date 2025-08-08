#!/bin/bash

# Initialize center view to state 0 (Spotify)
# This should be called on sketchybar startup

# Set initial state
echo "0" > $HOME/.config/sketchybar/.center_state

# Hide all non-Spotify items
sketchybar --set youtube_music.artwork drawing=off \
           --set youtube_music.anchor drawing=off \
           --set youtube_music.controls drawing=off \
           --set youtube_music.progress drawing=off \
           --set task drawing=off \
           --set pomodoro_work drawing=off \
           --set pomodoro_history drawing=off \
           --set pomodoro_break_history drawing=off

# Hide pomodoro break if it exists
if sketchybar --query pomodoro_break &>/dev/null; then
    sketchybar --set pomodoro_break drawing=off
fi

# Show Spotify items
sketchybar --set spotify.artwork drawing=on \
           --set spotify.anchor drawing=on \
           --set spotify.menubar_controls drawing=on \
           --set spotify.progress drawing=on