#!/bin/bash

# Navigate through history dates
# Usage: history_navigate.sh [prev|next]

HISTORY_DATE_FILE="/tmp/sketchybar_history_date"
STATE_FILE="$HOME/.config/sketchybar/.center_state"
TRACKING_DIR="$HOME/tracking"

# Only work if we're in history view (state 1)
if [ -f "$STATE_FILE" ]; then
    CURRENT_STATE=$(cat "$STATE_FILE")
    if [ "$CURRENT_STATE" != "1" ]; then
        # Not in history view, do nothing
        exit 0
    fi
fi

# Get current date
if [ -f "$HISTORY_DATE_FILE" ]; then
    CURRENT_DATE=$(cat "$HISTORY_DATE_FILE")
else
    CURRENT_DATE=$(date '+%Y-%m-%d')
fi

# Navigate based on argument
if [ "$1" = "prev" ]; then
    # Go to previous day
    NEW_DATE=$(date -j -v-1d -f "%Y-%m-%d" "$CURRENT_DATE" "+%Y-%m-%d" 2>/dev/null || date -d "$CURRENT_DATE -1 day" "+%Y-%m-%d")
elif [ "$1" = "next" ]; then
    # Go to next day (but not beyond today)
    TODAY=$(date '+%Y-%m-%d')
    NEXT_DATE=$(date -j -v+1d -f "%Y-%m-%d" "$CURRENT_DATE" "+%Y-%m-%d" 2>/dev/null || date -d "$CURRENT_DATE +1 day" "+%Y-%m-%d")
    
    # Don't go beyond today
    if [[ "$NEXT_DATE" > "$TODAY" ]]; then
        NEW_DATE="$TODAY"
    else
        NEW_DATE="$NEXT_DATE"
    fi
else
    exit 1
fi

# Save new date
echo "$NEW_DATE" > "$HISTORY_DATE_FILE"

# Refresh history display
bash "$HOME/.config/sketchybar/plugins/stopwatch_history.sh"

# Ensure history items are visible
for i in {0..9}; do
    sketchybar --set history_mode_$i drawing=on 2>/dev/null
done
sketchybar --set history_date drawing=on 2>/dev/null