#!/bin/bash

# Simple stopwatch item with click handler
sketchybar --add item stopwatch center \
           --set stopwatch label="00:00" \
                          label.color=$WHITE \
                          icon="⏱️" \
                          icon.color=$WHITE \
                          click_script="$PLUGIN_DIR/stopwatch.sh"