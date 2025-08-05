#!/bin/bash

# Toggle force repeat flag
FORCE_REPEAT_FILE="$HOME/.config/sketchybar/.force_repeat"
FORCE_REPEAT_DIR="$HOME/.config/sketchybar"

# Ensure directory exists
mkdir -p "$FORCE_REPEAT_DIR"

if [ -f "$FORCE_REPEAT_FILE" ]; then
    # Force repeat is ON, turn it OFF
    rm "$FORCE_REPEAT_FILE"
    echo "Force repeat: OFF"
else
    # Force repeat is OFF, turn it ON
    touch "$FORCE_REPEAT_FILE"
    echo "Force repeat: ON"
fi

# Trigger sketchybar update to reflect the change
sketchybar --trigger spotify_update