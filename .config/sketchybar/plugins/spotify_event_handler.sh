#!/bin/bash

# This script is called by spotify_player whenever a player event occurs
# Arguments: $1 = event_type, $2 = track_id, $3 = position_ms (for Playing/Paused)

# Path to spotify command wrapper
SPOTIFY_CMD="/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh"
export SPOTIFY_SOURCE="event_handler"

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
    # New track started - for now just trigger update
    # Auto-reset is handled in display script with better context detection
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
    # Check if force-repeat is enabled
    if [ -f "$HOME/.config/sketchybar/.force_repeat" ]; then
      # Log for debugging
      echo "$(date): Force repeat active, sending previous command" >> /tmp/spotify_force_repeat.log
      
      # Small delay to ensure track has actually ended
      sleep 0.5
      
      # Send previous command to restart the track
      $SPOTIFY_CMD playback previous
      
      # Log result
      echo "$(date): Previous command sent" >> /tmp/spotify_force_repeat.log
    fi
    
    # Always trigger update after track end
    trigger_update
    ;;
esac