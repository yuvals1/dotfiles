#!/bin/bash

# Path to the daemon-enabled spotify_player binary
# Built with: cargo build --release --no-default-features --features daemon,image,notify,rodio-backend
SPOTIFY="/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player"

# Check if daemon is already running
if ! pgrep -f "spotify_player --daemon" > /dev/null; then
  echo "Starting spotify_player daemon..."
  $SPOTIFY --daemon &
  
  # Give daemon time to start
  sleep 2
  
  # Verify daemon started
  if pgrep -f "spotify_player --daemon" > /dev/null; then
    echo "spotify_player daemon started successfully"
  else
    echo "Failed to start spotify_player daemon"
    exit 1
  fi
else
  echo "spotify_player daemon already running"
fi