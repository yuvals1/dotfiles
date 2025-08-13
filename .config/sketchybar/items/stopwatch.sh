#!/bin/bash

# Get initial icon based on current mode
MODE_FILE="/tmp/sketchybar_stopwatch_mode"
CONFIG_DIR="$HOME/.config/sketchybar"
CONFIG_FILE="$CONFIG_DIR/stopwatch_modes.conf"

# Initialize with work mode if no mode set
if [ ! -f "$MODE_FILE" ]; then
    echo "work" > "$MODE_FILE"
fi

# Get icon and label for current mode
CURRENT_MODE=$(cat "$MODE_FILE")
ICON="⏱️"  # Default
LABEL="Ready"  # Default

while IFS='|' read -r mode icon label; do
    [[ "$mode" =~ ^#.*$ ]] && continue
    [[ -z "$mode" ]] && continue
    
    if [[ "$mode" == "$CURRENT_MODE" ]]; then
        ICON="$icon"
        LABEL="$label"
        break
    fi
done < "$CONFIG_FILE"

# Simple stopwatch item with click handler - show mode name when idle
sketchybar --add item stopwatch center \
           --set stopwatch label="$LABEL" \
                          label.color=$WHITE \
                          icon="$ICON" \
                          icon.color=$WHITE \
                          click_script="$PLUGIN_DIR/stopwatch.sh"