#!/bin/bash

# Kill any existing input source monitor
pkill -f "input_source_monitor.swift" 2>/dev/null

# Launch the Swift helper in background
# Using caffeinate to prevent it from being killed on sleep
caffeinate -i ~/.config/sketchybar/helpers/input_source_monitor.swift &