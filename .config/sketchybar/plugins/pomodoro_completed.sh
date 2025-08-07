#!/bin/bash

# Check if completed pomodoro file exists
if [ -f "$HOME/.config/sketchybar/pomodoro/.completed_pomodoro" ]; then
    sketchybar --set $NAME drawing=on
else
    sketchybar --set $NAME drawing=off
fi