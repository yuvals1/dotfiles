#!/bin/bash

# Reset history date to today on sketchybar reload
rm -f /tmp/sketchybar_history_date

# We'll create individual items for each mode dynamically
# Just create a placeholder that the plugin will manage
sketchybar --add item stopwatch_history center \
           --set stopwatch_history drawing=off