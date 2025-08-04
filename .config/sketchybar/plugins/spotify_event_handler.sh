#!/bin/bash

# This script is called by spotify_player whenever a player event occurs
# Arguments: $1 = event_type, $2 = track_id, $3 = position_ms (for Playing/Paused)

# Path to spotify_player for getting detailed info
SPOTIFY="/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player"

# Function to trigger sketchybar update
trigger_update() {
  # Add a small delay to ensure spotify_player's state is updated
  sleep 0.1
  
  # Trigger the display script to update
  sketchybar --trigger spotify_update &>/dev/null
}

# Log events for debugging (optional - comment out in production)
# echo "$(date): Event: $1, Track: $2, Position: ${3:-N/A}" >> /tmp/spotify_events.log

case "$1" in
  "Changed")
    # New track started - immediate update needed
    trigger_update
    ;;
  
  "Playing")
    # Playback resumed - update play/pause icon
    trigger_update
    ;;
  
  "Paused")
    # Playback paused - update play/pause icon
    trigger_update
    ;;
  
  "EndOfTrack")
    # Track ended - might switch to next track automatically
    # Add small delay to catch the next track
    sleep 0.5
    trigger_update
    ;;
esac