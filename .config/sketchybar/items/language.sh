#!/bin/bash

# Add language indicator to the right side
sketchybar --add item language right \
           --set language label="A" \
                         label.color=$WHITE \
                         label.font="$FONT:Bold:16.0" \
                         background.color=$ITEM_BG_COLOR \
                         background.corner_radius=$CORNER_RADIUS \
                         background.height=24 \
                         padding_left=10 \
                         padding_right=10 \
                         script="$PLUGIN_DIR/language.sh" \
                         click_script="$PLUGIN_DIR/language.sh"