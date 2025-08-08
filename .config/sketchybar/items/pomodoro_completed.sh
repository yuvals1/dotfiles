#!/bin/bash

sketchybar --add item pomodoro_completed right \
           --set pomodoro_completed icon=❗ \
                                    label="No timer" \
                                    drawing=off \
                                    script="$PLUGIN_DIR/pomodoro_completed.sh" \
           --subscribe pomodoro_completed pomodoro_update