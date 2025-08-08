#!/bin/bash

#!/bin/bash

# Source common configuration to get time functions
source "$CONFIG_DIR/pomodoro_common.sh"

# Create single timer item
# Left-click starts/stops Work via plugin; Break can be controlled via hotkey or secondary binding
sketchybar --add item pomodoro_timer center \
           --set pomodoro_timer label="⏰" \
                 label.color=$WHITE \
                 click_script="NAME=work $PLUGIN_DIR/pomodoro.sh"
