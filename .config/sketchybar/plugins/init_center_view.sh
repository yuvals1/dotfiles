#!/bin/bash

# Initialize center view to state 0 (Pomodoro)
# This should be called on sketchybar startup

# Set initial state
echo "0" > $HOME/.config/sketchybar/.center_state

# Hide all non-Pomodoro items
sketchybar --set youtube_music.artwork drawing=off \
           --set youtube_music.anchor drawing=off \
           --set youtube_music.controls drawing=off \
           --set youtube_music.progress drawing=off \
           --set spotify.artwork drawing=off \
           --set spotify.anchor drawing=off \
           --set spotify.menubar_controls drawing=off \
           --set spotify.progress drawing=off \
           --set spotify.context drawing=off

# No separate break button anymore

# Show Pomodoro items
sketchybar --set task drawing=on \
           --set pomodoro_timer drawing=on \
           --set pomodoro_history drawing=on \
           --set pomodoro_break_history drawing=on