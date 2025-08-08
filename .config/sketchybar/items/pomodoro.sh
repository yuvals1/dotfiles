#!/bin/bash

#!/bin/bash

# Source common configuration to get time functions
source "$CONFIG_DIR/pomodoro_common.sh"

# Get current configured times
WORK_TIME=$(get_work_minutes)
BREAK_TIME=$(get_break_minutes)
WORK_DISPLAY=$(printf "%02d:00" $WORK_TIME)
BREAK_DISPLAY=$(printf "%02d:00" $BREAK_TIME)

# Create single timer item
# Left-click starts/stops Work via plugin; Break can be controlled via hotkey or secondary binding
sketchybar --add item pomodoro_timer center \
           --set pomodoro_timer label="🍅 ${WORK_DISPLAY} · ☕️ ${BREAK_DISPLAY}" \
                 label.color=$WHITE \
                 click_script="NAME=work $PLUGIN_DIR/pomodoro.sh"
