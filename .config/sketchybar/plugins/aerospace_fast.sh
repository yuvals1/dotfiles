#!/usr/bin/env bash

# This plugin handles aerospace workspace events
# It's called with the workspace ID as $1

source "$CONFIG_DIR/colors.sh" # Load colors

# Get the currently focused workspace directly from aerospace
CURRENT_FOCUSED=$(aerospace list-workspaces --focused)

# Check if this space is the focused one
if [ "$1" = "$CURRENT_FOCUSED" ]; then
    # Active workspace - inverted colors with subtle shadow
    sketchybar --set $NAME \
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
    sketchybar --set $NAME \
        background.drawing=off \
        icon.color=$ACCENT_COLOR \
        label.color=$ACCENT_COLOR \
        background.shadow.drawing=off
fi

# Update app icons for this workspace
if [ "$SENDER" = "aerospace_workspace_change" ] || [ "$SENDER" = "forced" ]; then
    # Tiny delay to let aerospace settle (prevents race conditions)
    sleep 0.02
    
    # Get all apps in this workspace with deduplication
    apps=$(aerospace list-windows --workspace $1 --format "%{app-name}" 2>/dev/null | sort -u)
    
    icon_strip=" "
    if [ "${apps}" != "" ]; then
        while read -r app; do
            # Get icon for each unique app
            icon_result=$($CONFIG_DIR/plugins/icon_map_fn.sh "$app")
            icon_strip+="${icon_result} "
        done <<< "${apps}"
    else
        icon_strip=" —"
    fi
    
    sketchybar --set $NAME label="$icon_strip"
fi