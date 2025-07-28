#!/bin/bash

sketchybar --add item overdue right \
           --set overdue update_freq=60 \
                        icon=⏰ \
                        drawing=off \
                        script="$PLUGIN_DIR/overdue_checker.sh"