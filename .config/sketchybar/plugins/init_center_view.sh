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

# Show timer icon for stopwatch state
sketchybar --set stopwatch_icon drawing=on

# Check if stopwatch is running (using start file instead of PID)
START_FILE="/tmp/sketchybar_stopwatch_start"
if [ -f "$START_FILE" ]; then
    # Stopwatch is running - show it and ensure updates are on
    sketchybar --set stopwatch drawing=on update_freq=1
else
    # Stopwatch is idle - show mode options
    sketchybar --set stopwatch drawing=off update_freq=0
    bash "$HOME/.config/sketchybar/plugins/stopwatch.sh" render_modes
fi