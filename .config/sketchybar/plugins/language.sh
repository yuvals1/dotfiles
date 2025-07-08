#!/bin/bash

# Get current input source
INPUT_SOURCE=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | grep -o '"KeyboardLayout Name" = [^;]*' | tail -1 | sed 's/.*= //; s/;//')

# Set display based on language
case "$INPUT_SOURCE" in
    "Hebrew")
        DISPLAY="א"
        ;;
    "ABC"|"U.S.")
        DISPLAY="A"
        ;;
    *)
        # For other languages, show first letter or abbreviation
        DISPLAY="${INPUT_SOURCE:0:2}"
        ;;
esac

# Update sketchybar
sketchybar --set language label="$DISPLAY"

# Handle click to switch input source
if [ "$SENDER" = "mouse.clicked" ]; then
    # Switch to next input source
    osascript -e 'tell application "System Events" to key code 49 using {command down, option down}'
fi