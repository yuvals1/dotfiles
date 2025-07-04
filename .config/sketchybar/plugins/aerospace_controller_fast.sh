#!/usr/bin/env bash

# Optimized controller that updates all workspaces efficiently

source "$CONFIG_DIR/colors.sh"

# Get the currently focused workspace directly from aerospace
FOCUSED=$(aerospace list-workspaces --focused)

# Start batch mode
BATCH_CMD="--batch "

# Update all workspaces in a single pass
for sid in $(aerospace list-workspaces --all); do
  # Get window count and apps in one query
  apps=$(aerospace list-windows --workspace $sid --format "%{app-name}" 2>/dev/null)
  
  # Quick check if empty
  if [ -z "$apps" ]; then
    window_count=0
    icon_strip=" —"
  else
    window_count=1  # We know there's at least one
    icon_strip=" "
    while read -r app; do
      icon_result=$($CONFIG_DIR/plugins/icon_map_fn.sh "$app")
      icon_strip+="${icon_result} "
    done <<< "$apps"
  fi
  
  # Build the update command
  if [ "$sid" = "$FOCUSED" ]; then
    # Active workspace - always visible
    BATCH_CMD+="--set space.$sid background.drawing=on background.color=$ACCENT_COLOR icon.color=$BAR_COLOR label.color=$BAR_COLOR background.shadow.drawing=on label=\"$icon_strip\" drawing=on "
  else
    # Inactive workspace
    if [ $window_count -gt 0 ]; then
      BATCH_CMD+="--set space.$sid background.drawing=off icon.color=$ACCENT_COLOR label.color=$ACCENT_COLOR background.shadow.drawing=off label=\"$icon_strip\" drawing=on "
    else
      BATCH_CMD+="--set space.$sid drawing=off "
    fi
  fi
done

# Execute all updates in a single sketchybar call
eval "sketchybar $BATCH_CMD"