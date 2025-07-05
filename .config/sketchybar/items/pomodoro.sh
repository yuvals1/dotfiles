#!/bin/bash

# Create work button (tomato)
sketchybar --add item pomodoro_work center \
           --set pomodoro_work label="🍅" \
                 label.color=$WHITE \
                 click_script="NAME=work $PLUGIN_DIR/pomodoro.sh"

# Create break button (coffee)
sketchybar --add item pomodoro_break center \
           --set pomodoro_break label="☕️" \
                 label.color=$WHITE \
                 click_script="NAME=break $PLUGIN_DIR/pomodoro.sh"