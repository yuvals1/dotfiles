#!/bin/bash

POMO_DIR="$HOME/.config/sketchybar/pomodoro"
POMO_HISTORY="$POMO_DIR/.pomodoro_history"

# Get today's date
TODAY=$(date '+%Y-%m-%d')

# Initialize total minutes
total_minutes=0

if [ -f "$POMO_HISTORY" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        # Extract date from timestamp
        LINE_DATE=$(echo "$line" | cut -d' ' -f1)
        
        # Only process today's sessions (both work and breaks)
        if [[ "$LINE_DATE" == "$TODAY" ]]; then
            # Extract minutes from the line (format: "X mins")
            minutes=$(echo "$line" | grep -o '[0-9]* mins' | awk '{print $1}')
            if [ -n "$minutes" ]; then
                total_minutes=$((total_minutes + minutes))
            fi
        fi
    done < "$POMO_HISTORY"
fi

# Convert to hours with 1 decimal place
# Use printf to ensure consistent decimal formatting
hours=$(printf "%.1f" $(echo "scale=2; $total_minutes / 60" | bc))

# Update display
sketchybar --set pomodoro_history label="⏱️ ${hours}h"