#!/bin/bash

# Remove any existing space items first
for i in {1..10}; do
  sketchybar --remove space.$i 2>/dev/null
done

# Dynamically create spaces based on aerospace workspaces
for sid in $(aerospace list-workspaces --all); do
  sketchybar --add item space.$sid left \
    --set space.$sid \
      icon=$sid \
      label.font="sketchybar-app-font:Regular:16.0" \
      label.padding_right=20 \
      label.y_offset=-1 \
      label="" \
      script="$PLUGIN_DIR/aerospace_fast.sh $sid" \
      click_script="aerospace workspace $sid" \
    --subscribe space.$sid aerospace_workspace_change
done

# Add space separator
sketchybar --add item space_separator left \
  --set space_separator \
    icon="􀆊" \
    icon.color=$ACCENT_COLOR \
    icon.padding_left=4 \
    label.drawing=off \
    background.drawing=off \
    script="$PLUGIN_DIR/space_windows_fast.sh" \
  --subscribe space_separator aerospace_workspace_change

# Initial update
for sid in $(aerospace list-workspaces --all); do
  sh $PLUGIN_DIR/aerospace_fast.sh $sid
done
sh $PLUGIN_DIR/space_windows_fast.sh