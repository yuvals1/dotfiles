#!/bin/bash

# Add break-only history display to the center
sketchybar --add item pomodoro_break_history center \
           --set pomodoro_break_history label="☕️ 0.0h" \
                 label.color=$WHITE \
                 script="$PLUGIN_DIR/pomodoro_break_history.sh" \
           --subscribe pomodoro_break_history pomodoro_update
