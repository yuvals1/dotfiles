#!/bin/bash

# YouTube Music API endpoint
API_URL="http://0.0.0.0:26538/api/v1"

# For now, just toggle play/pause on any click
curl -s -X POST "$API_URL/toggle-play" &>/dev/null

# Trigger update after a short delay
sleep 0.2
sketchybar --trigger youtube_music_update &