#!/bin/bash

# Add language indicator to the right side
sketchybar --add item language right \
           --set language icon="🇺🇸" \
                         label="EN" \
                         script="$PLUGIN_DIR/language.sh" \
                         click_script="$PLUGIN_DIR/language.sh"