#!/bin/bash

# Initialize center view to state 0 (Stopwatch)
# This should be called on sketchybar startup

# Set initial state
echo "0" > $HOME/.config/sketchybar/.center_state

# Hide all non-stopwatch items
sketchybar --set youtube_music.artwork drawing=off \
           --set youtube_music.anchor drawing=off \
           --set youtube_music.controls drawing=off \
           --set youtube_music.progress drawing=off \
           --set spotify.artwork drawing=off \
           --set spotify.anchor drawing=off \
           --set spotify.menubar_controls drawing=off \
           --set spotify.progress drawing=off \
           --set spotify.context drawing=off \
           --set stopwatch_history drawing=off \
           --set task drawing=off \
           --set pomodoro_timer drawing=off \
           --set pomodoro_history drawing=off \
           --set pomodoro_break_history drawing=off

# Show timer icon for stopwatch state
sketchybar --set stopwatch_icon drawing=on

# Check if stopwatch is running (using start file instead of PID)
START_FILE="/tmp/sketchybar_stopwatch_start"
MODE_FILE="/tmp/sketchybar_stopwatch_mode"
CONFIG_FILE="$HOME/personal/tracking/stopwatch_modes.conf"
CONFIG_DIR="$HOME/.config/sketchybar"

# Source colors
source "$CONFIG_DIR/colors.sh"

if [ -f "$START_FILE" ]; then
    # Stopwatch is running - restore appearance and ensure updates are on
    MODE=$(cat "$MODE_FILE" 2>/dev/null || echo "OSE")
    
    # Get mode appearance from config
    while IFS='|' read -r m icon color; do
        [[ "$m" =~ ^#.*$ ]] && continue
        [[ -z "$m" ]] && continue
        
        if [[ "$m" == "$MODE" ]]; then
            # Map color names to actual colors
            case "$color" in
                "blue") COLOR="0xff4a90e2" ;;
                "red") COLOR="0xffff6b6b" ;;
                "yellow") COLOR="0xffffeb3b" ;;
                "green") COLOR="$GREEN" ;;
                "purple") COLOR="0xff9370db" ;;
                "teal") COLOR="$ACCENT_COLOR" ;;
                "orange") COLOR="$ORANGE" ;;
                *) COLOR="$ITEM_BG_COLOR" ;;
            esac
            
            # Set text color
            LABEL_COLOR="$WHITE"
            if [[ "$color" == "yellow" ]]; then
                LABEL_COLOR="$BLACK"
            fi
            
            # Restore full appearance
            sketchybar --set stopwatch drawing=on \
                                      update_freq=1 \
                                      icon="$icon" \
                                      background.color="$COLOR" \
                                      background.drawing=on \
                                      label.color="$LABEL_COLOR" \
                                      icon.color="$LABEL_COLOR"
            break
        fi
    done < "$CONFIG_FILE"
else
    # Stopwatch is idle - show mode options
    sketchybar --set stopwatch drawing=off update_freq=0
    bash "$HOME/.config/sketchybar/plugins/stopwatch.sh" render_modes
fi