#!/bin/bash

sketchybar --add item audio right \
           --set audio \
                 script="$PLUGIN_DIR/audio.sh" \
                 update_freq=10 \
           --subscribe audio volume_change