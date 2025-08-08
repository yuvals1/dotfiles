#!/bin/bash

# Create event for pomodoro updates
sketchybar --add event pomodoro_update

# Add history display to the center
sketchybar --add item pomodoro_history center \
           --set pomodoro_history label="🍅 0.0h" \
                 label.color=$WHITE \
                 script="$PLUGIN_DIR/pomodoro_history.sh" \
           --subscribe pomodoro_history pomodoro_update