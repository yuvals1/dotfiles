#!/usr/bin/env bash

# This plugin handles aerospace workspace events
# It's called with the workspace ID as $1

source "$CONFIG_DIR/theme.sh" # Load colors

# Get the currently focused workspace directly from aerospace
CURRENT_FOCUSED=$(aerospace list-workspaces --focused)

# Check if this space is the focused one
if [ "$1" = "$CURRENT_FOCUSED" ]; then
    # Active workspace - bright green with glow effect
    sketchybar --set $NAME \
        background.drawing=on \
        background.color=$WORKSPACE_ACTIVE \
        background.border_color=0x80ffffff \
        background.border_width=1 \
        icon.color=0xff000000 \
        icon.highlight=on \
        icon.highlight_color=0xff000000 \
        label.color=0xff000000 \
        label.highlight=on \
        label.highlight_color=0xff000000 \
        background.shadow.drawing=on \
        background.shadow.color=$WORKSPACE_ACTIVE \
        background.shadow.angle=0 \
        background.shadow.distance=0 \
        background.blur_radius=30
else
    # Inactive workspace - subtle background with muted colors
    sketchybar --set $NAME \
        background.drawing=on \
        background.color=0x30ffffff \
        background.border_color=0x20ffffff \
        background.border_width=1 \
        icon.color=0xc0ffffff \
        icon.highlight=off \
        label.color=0x80ffffff \
        label.highlight=off \
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