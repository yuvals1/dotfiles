#!/bin/bash

# Source common configuration to get time functions
source "$CONFIG_DIR/pomodoro_common.sh"

# Get current configured times
WORK_TIME=$(get_work_minutes)
BREAK_TIME=$(get_break_minutes)
WORK_DISPLAY=$(printf "%02d:00" $WORK_TIME)
BREAK_DISPLAY=$(printf "%02d:00" $BREAK_TIME)

# Create work button (tomato)
sketchybar --add item pomodoro_work center \
           --set pomodoro_work label="🍅 ${WORK_DISPLAY}" \
                 label.color=$WHITE \
                 click_script="NAME=work $PLUGIN_DIR/pomodoro.sh"

# Create break button (coffee)
sketchybar --add item pomodoro_break center \
           --set pomodoro_break label="☕️ ${BREAK_DISPLAY}" \
                 label.color=$WHITE \
                 click_script="NAME=break $PLUGIN_DIR/pomodoro.sh"
