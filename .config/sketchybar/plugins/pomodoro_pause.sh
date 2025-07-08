#!/bin/bash

# Source common configuration
PLUGIN_DIR="$(dirname "$0")"
source "$(dirname "$PLUGIN_DIR")/pomodoro_common.sh"

# Toggle pause state
if [ -f "$PAUSE_FILE" ]; then
    # Currently paused - resume
    rm -f "$PAUSE_FILE"
else
    # Currently running - check if timer is active
    if [ -f "$PID_FILE" ] && [ -f "$MODE_FILE" ]; then
        # Timer is running, pause it
        touch "$PAUSE_FILE"
    fi
fi