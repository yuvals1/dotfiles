#!/bin/bash

# Add history display to the center
sketchybar --add item pomodoro_history center \
           --set pomodoro_history label="✅ 0" \
                 label.color=$WHITE \
                 update_freq=60 \
                 script="$PLUGIN_DIR/pomodoro_history.sh" \
                 click_script="SENDER=mouse.clicked $PLUGIN_DIR/pomodoro_history.sh"