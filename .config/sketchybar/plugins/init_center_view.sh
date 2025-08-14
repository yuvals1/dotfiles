#!/bin/bash

# Initialize center view to state 0 (Stopwatch)
# This should be called on sketchybar startup

# Set initial state
echo "0" > $HOME/.config/sketchybar/.center_state

# Hide all non-stopwatch items
sketchybar --set youtube_music.artwork drawing=off \
           --set youtube_music.anchor drawing=off \
           --set youtube_music.controls drawing=off \
           --set youtube_music.progress drawing=off \
           --set spotify.artwork drawing=off \
           --set spotify.anchor drawing=off \
           --set spotify.menubar_controls drawing=off \
           --set spotify.progress drawing=off \
           --set spotify.context drawing=off \
           --set stopwatch_history drawing=off \
           --set task drawing=off \
           --set pomodoro_timer drawing=off \
           --set pomodoro_history drawing=off \
           --set pomodoro_break_history drawing=off

# Show mode options (idle view) and hide stopwatch item
sketchybar --set stopwatch drawing=off
bash "$HOME/.config/sketchybar/plugins/render_stopwatch_modes.sh"