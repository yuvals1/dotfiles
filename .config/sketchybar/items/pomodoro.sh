#!/bin/bash

# Create a simple work button in the center
sketchybar --add item pomodoro center \
           --set pomodoro label="🍅" \
                 label.color=$WHITE \
                 click_script="$PLUGIN_DIR/pomodoro_simple.sh"