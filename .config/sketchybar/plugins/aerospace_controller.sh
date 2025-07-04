#!/usr/bin/env bash

# Single controller that updates all workspaces based on aerospace's actual state
# This eliminates race conditions from multiple event handlers

source "$CONFIG_DIR/colors.sh"

# Get the currently focused workspace directly from aerospace
FOCUSED=$(aerospace list-workspaces --focused)

# Update all workspaces in a single pass
for sid in $(aerospace list-workspaces --all); do
  if [ "$sid" = "$FOCUSED" ]; then
    # Active workspace - inverted colors with subtle shadow
    sketchybar --set space.$sid \
      background.drawing=on \
      background.color=$ACCENT_COLOR \
      icon.color=$BAR_COLOR \
      label.color=$BAR_COLOR \
      background.shadow.drawing=on \
      background.shadow.color=0x30000000 \
      background.shadow.angle=45 \
      background.shadow.distance=2
  else
    # Inactive workspace - normal colors
    sketchybar --set space.$sid \
      background.drawing=off \
      icon.color=$ACCENT_COLOR \
      label.color=$ACCENT_COLOR \
      background.shadow.drawing=off
  fi
  
  # Update app icons for this workspace
  apps=$(aerospace list-windows --workspace $sid --format "%{app-name}" 2>/dev/null)
  
  icon_strip=" "
  if [ "${apps}" != "" ]; then
    while read -r app; do
      icon_result=$($CONFIG_DIR/plugins/icon_map_fn.sh "$app")
      icon_strip+="${icon_result} "
    done <<< "${apps}"
  else
    icon_strip=" —"
  fi
  
  sketchybar --set space.$sid label="$icon_strip"
  
  # Hide empty workspaces (except the focused one)
  window_count=$(aerospace list-windows --workspace $sid 2>/dev/null | wc -l)
  if [ $window_count -gt 0 ] || [ "$sid" = "$FOCUSED" ]; then
    sketchybar --set space.$sid drawing=on
  else
    sketchybar --set space.$sid drawing=off
  fi
done