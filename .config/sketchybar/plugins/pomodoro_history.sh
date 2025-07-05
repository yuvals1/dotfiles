#!/bin/bash

POMO_HISTORY="$HOME/.config/sketchybar/pomodoro/.pomodoro_history"
today=$(date '+%Y-%m-%d')

count=0

if [ -f "$POMO_HISTORY" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" == "$today"* ]] && [[ "$line" == *"[WORK]"* ]]; then
            count=$((count + 1))
        fi
    done < "$POMO_HISTORY"
fi

sketchybar --set pomodoro_history label="✅ $count"