#!/bin/bash

CALENDAR_DIR="${CALENDAR_DIR:-$HOME/personal/calendar}"
OVERDUE_DIR="$CALENDAR_DIR/overdue"

# Count files in overdue directory
overdue_count=$(find "$OVERDUE_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')

if [ "$overdue_count" -gt 0 ]; then
    sketchybar --set $NAME label="$overdue_count" drawing=on
else
    sketchybar --set $NAME drawing=off
fi