#!/bin/bash

# Create task display item
sketchybar --add item task center \
           --set task label="" \
                 icon="" \
                 icon.color=$WHITE \
                 label.color=$WHITE \
                 background.color=$ITEM_BG_COLOR \
                 background.corner_radius=5 \
                 background.height=24 \
                 padding_left=5 \
                 padding_right=5 \
                 label.padding_left=4 \
                 label.padding_right=10 \
                 icon.padding_left=10 \
                 icon.padding_right=4 \
                 script="$PLUGIN_DIR/task.sh" \
                 click_script="$PLUGIN_DIR/task.sh"

