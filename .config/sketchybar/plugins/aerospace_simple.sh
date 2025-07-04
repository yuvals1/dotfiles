#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

# Get focused workspace once
FOCUSED=$(aerospace list-workspaces --focused)

# First, update all workspaces to ensure they exist
for sid in $(aerospace list-workspaces --all); do
  # Get apps for this specific workspace
  apps=$(aerospace list-windows --workspace $sid --format "%{app-name}" 2>/dev/null)
  
  icon_strip=" "
  if [ -n "$apps" ]; then
    while read -r app; do
      if [ -n "$app" ]; then
        icon=$($CONFIG_DIR/plugins/icon_map_fn.sh "$app")
        icon_strip+="$icon "
      fi
    done <<< "$apps"
  else
    icon_strip=" —"
  fi
  
  if [ "$sid" = "$FOCUSED" ]; then
    # Active workspace
    sketchybar --set space.$sid \
      background.drawing=on \
      background.color=$ACCENT_COLOR \
      icon.color=$BAR_COLOR \
      label.color=$BAR_COLOR \
      label="$icon_strip" \
      drawing=on
  else
    # Inactive workspace
    if [ -n "$apps" ]; then
      sketchybar --set space.$sid \
        background.drawing=off \
        icon.color=$ACCENT_COLOR \
        label.color=$ACCENT_COLOR \
        label="$icon_strip" \
        drawing=on
    else
      sketchybar --set space.$sid drawing=off
    fi
  fi
done