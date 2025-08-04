#!/bin/bash

# This can be added to sketchybar to monitor daemon health
# Add to sketchybarrc:
# sketchybar --add item spotify.health right \
#            --set spotify.health update_freq=60 \
#                                 script="$PLUGIN_DIR/spotify_health_check.sh"

source "$CONFIG_DIR/colors.sh"

RESTART_SCRIPT="$PLUGIN_DIR/spotify_daemon_restart.sh"

# Check daemon health
if $RESTART_SCRIPT check >/dev/null 2>&1; then
    # Healthy - hide icon
    sketchybar --set $NAME drawing=off
else
    # Unhealthy - show warning
    sketchybar --set $NAME \
        drawing=on \
        icon="⚠️" \
        label="Spotify daemon issue" \
        icon.color=$ACCENT_COLOR \
        click_script="$RESTART_SCRIPT restart; sleep 1; sketchybar --set $NAME drawing=off"
fi