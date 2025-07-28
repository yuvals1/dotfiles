#!/bin/bash

# Get current input source
INPUT_SOURCE=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | grep -o '"KeyboardLayout Name" = [^;]*' | tail -1 | sed 's/.*= //; s/;//')

# Set flag emoji based on language
case "$INPUT_SOURCE" in
    "Hebrew")
        ICON="🇮🇱"
        LABEL="HE"
        ;;
    "ABC"|"U.S."|"US")
        ICON="🇺🇸"
        LABEL="EN"
        ;;
    *)
        # For other languages, show generic flag and abbreviation
        ICON="🏳️"
        LABEL="${INPUT_SOURCE:0:2}"
        ;;
esac

# Update sketchybar with icon and label
sketchybar --set language icon="$ICON" label="$LABEL"

# Handle click to switch input source
if [ "$SENDER" = "mouse.clicked" ]; then
    # Switch to next input source
    osascript -e 'tell application "System Events" to key code 49 using {command down, option down}'
fi