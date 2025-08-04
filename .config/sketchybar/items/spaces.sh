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
      icon.font="SF Pro:Bold:14.0" \
      icon.padding_left=8 \
      icon.padding_right=8 \
      label.font="sketchybar-app-font:Regular:14.0" \
      label.padding_right=8 \
      label.padding_left=2 \
      label.y_offset=-1 \
      label="" \
      padding_left=2 \
      padding_right=2 \
      background.corner_radius=6 \
      background.height=26 \
      script="$PLUGIN_DIR/aerospace_fast.sh $sid" \
      click_script="aerospace workspace $sid" \
    --subscribe space.$sid aerospace_workspace_change
done

# Add space separator
sketchybar --add item space_separator left \
  --set space_separator \
    icon="│" \
    icon.font="SF Pro:Regular:20.0" \
    icon.color=0x30ffffff \
    icon.padding_left=8 \
    icon.padding_right=8 \
    icon.y_offset=-1 \
    label.drawing=off \
    background.drawing=off \
    script="$PLUGIN_DIR/space_windows_fast.sh" \
  --subscribe space_separator aerospace_workspace_change

# Initial update with slight stagger to prevent flicker
focused=$(aerospace list-workspaces --focused)
for sid in $(aerospace list-workspaces --all); do
  # Update focused workspace first, others with slight delay
  if [ "$sid" = "$focused" ]; then
    sh $PLUGIN_DIR/aerospace_fast.sh $sid
  else
    (sleep 0.1 && sh $PLUGIN_DIR/aerospace_fast.sh $sid) &
  fi
done
sh $PLUGIN_DIR/space_windows_fast.sh