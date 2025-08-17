#!/bin/bash

# Source colors and icons
source "$HOME/.config/sketchybar/theme.sh"

sketchybar --add item overdue right \
           --set overdue update_freq=60 \
                        icon="$OVERDUE_ICON" \
                        drawing=off \
                        script="$PLUGIN_DIR/overdue_checker.sh"