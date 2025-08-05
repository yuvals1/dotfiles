#!/bin/bash

# Simple script to restart spotify_player daemon when sync issues occur
# Run this manually when you notice state sync problems

echo "Restarting spotify_player daemon..."

# Kill existing daemon
pkill -f "spotify_player --daemon" 2>/dev/null
sleep 1

# Start new daemon
/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player --daemon &
sleep 2

echo "Daemon restarted successfully"
echo "Current state:"
/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player get key playback 2>/dev/null | jq -r '.is_playing'