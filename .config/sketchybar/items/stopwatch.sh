#!/bin/bash

# Get initial icon based on current mode
MODE_FILE="/tmp/sketchybar_stopwatch_mode"
CONFIG_FILE="$HOME/personal/tracking/stopwatch_modes.conf"

# Initialize with OSE mode if no mode set
if [ ! -f "$MODE_FILE" ]; then
    echo "OSE" > "$MODE_FILE"
fi

# Get icon and label for current mode
CURRENT_MODE=$(cat "$MODE_FILE")
ICON="⏱️"  # Default
LABEL="Ready"  # Default

while IFS='|' read -r mode icon color; do
    [[ "$mode" =~ ^#.*$ ]] && continue
    [[ -z "$mode" ]] && continue
    
    if [[ "$mode" == "$CURRENT_MODE" ]]; then
        ICON="$icon"
        LABEL="$mode"
        break
    fi
done < "$CONFIG_FILE"

# Timer icon that shows when in stopwatch view (state 0)
sketchybar --add item stopwatch_icon center \
           --set stopwatch_icon icon="⏱️" \
                               icon.color=$WHITE \
                               icon.font="SF Pro:Regular:18.0" \
                               label="" \
                               padding_left=8 \
                               padding_right=4 \
                               drawing=on

# Simple stopwatch item with click handler - show mode name when idle
sketchybar --add item stopwatch center \
           --set stopwatch label="$LABEL" \
                          label.color=$WHITE \
                          icon="$ICON" \
                          icon.color=$WHITE \
                          click_script="$PLUGIN_DIR/stopwatch.sh" \
                          update_freq=0 \
                          updates=on \
                          script="$PLUGIN_DIR/stopwatch.sh tick"
