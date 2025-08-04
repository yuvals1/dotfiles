#!/bin/bash

# YouTube Music API endpoint
API_URL="http://0.0.0.0:26538/api/v1"

# Handle keyboard command
case "$1" in
  "shuffle")
    curl -s -X POST "$API_URL/shuffle" &>/dev/null
    ;;
  "repeat")
    # YouTube Music API doesn't have repeat endpoint
    # Could potentially use a notification here
    echo "Repeat not available in YouTube Music API"
    ;;
  "previous" | "prev")
    curl -s -X POST "$API_URL/previous" &>/dev/null
    ;;
  "play-pause")
    curl -s -X POST "$API_URL/toggle-play" &>/dev/null
    ;;
  "next")
    curl -s -X POST "$API_URL/next" &>/dev/null
    # Auto-play after next (similar to Spotify)
    sleep 0.3
    # Check if paused and play if needed
    SONG_INFO=$(curl -s "$API_URL/song-info" 2>/dev/null)
    if [ -n "$SONG_INFO" ] && [ "$SONG_INFO" != "null" ]; then
      IS_PAUSED=$(echo "$SONG_INFO" | jq -r '.isPaused')
      if [ "$IS_PAUSED" = "true" ]; then
        curl -s -X POST "$API_URL/play" &>/dev/null
      fi
    fi
    ;;
esac

# Trigger update after a short delay
sleep 0.2
sketchybar --trigger youtube_music_update &