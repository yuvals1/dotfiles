#!/bin/bash

CALENDAR_DIR="${CALENDAR_DIR:-$HOME/personal/calendar}"
OVERDUE_COUNT_FILE="$CALENDAR_DIR/overdue-count"

# Read overdue count from file
if [ -f "$OVERDUE_COUNT_FILE" ]; then
    overdue_count=$(cat "$OVERDUE_COUNT_FILE")
    sketchybar --set $NAME label="$overdue_count" drawing=on
else
    sketchybar --set $NAME drawing=off
fi