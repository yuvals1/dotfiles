#!/usr/bin/env bash

# This plugin updates workspace visibility based on whether they have windows
# It runs on aerospace_workspace_change events

source "$CONFIG_DIR/colors.sh"

# Update all workspaces
for sid in $(aerospace list-workspaces --all); do
  # Check if workspace has windows
  window_count=$(aerospace list-windows --workspace $sid 2>/dev/null | wc -l)
  
  if [ $window_count -gt 0 ]; then
    # Show workspace if it has windows
    sketchybar --set space.$sid drawing=on
    
    # Update app icons for this workspace
    apps=$(aerospace list-windows --workspace $sid --format "%{app-name}" 2>/dev/null)
    
    icon_strip=" "
    if [ "${apps}" != "" ]; then
      while read -r app; do
        # Get icon for each app instance
        icon_result=$($CONFIG_DIR/plugins/icon_map_fn.sh "$app")
        icon_strip+="${icon_result} "
      done <<< "${apps}"
    else
      icon_strip=" —"
    fi
    
    sketchybar --set space.$sid label="$icon_strip"
  else
    # Hide workspace if empty
    sketchybar --set space.$sid drawing=off
  fi
done

# Make sure current workspace is always visible
if [ -n "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set space.$FOCUSED_WORKSPACE drawing=on
fi