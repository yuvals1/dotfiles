#!/bin/bash

# Initialize center view to state 0 (Pomodoro)
# This should be called on sketchybar startup

# Set initial state
echo "0" > $HOME/.config/sketchybar/.center_state

# Hide all music items
sketchybar --set spotify.artwork drawing=off \
           --set spotify.anchor drawing=off \
           --set spotify.menubar_controls drawing=off \
           --set spotify.progress drawing=off \
           --set youtube_music.artwork drawing=off \
           --set youtube_music.anchor drawing=off \
           --set youtube_music.controls drawing=off \
           --set youtube_music.progress drawing=off

# Show pomodoro items (they start visible by default, but let's be explicit)
sketchybar --set task drawing=on \
           --set pomodoro_work drawing=on \
           --set pomodoro_history drawing=on

# Show break button if it exists
if sketchybar --query pomodoro_break &>/dev/null; then
    sketchybar --set pomodoro_break drawing=on
fi