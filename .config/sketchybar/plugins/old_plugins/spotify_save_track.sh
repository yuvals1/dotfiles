#!/bin/bash

# Path to spotify command wrapper
SPOTIFY_CMD="/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh"

# Directory to save song info
SAVE_DIR="$HOME/spotify/songs/current"

# Create directory if it doesn't exist
mkdir -p "$SAVE_DIR"

# Get current playback info
playback_json=$($SPOTIFY_CMD get key playback 2>/dev/null)

if [ -z "$playback_json" ] || [ "$playback_json" = "null" ]; then
    echo "No track currently playing"
    exit 1
fi

# Parse track name and artist
track=$(echo "$playback_json" | jq -r '.item.name // ""')
artist=$(echo "$playback_json" | jq -r '.item.artists[0].name // ""')

if [ -z "$track" ] || [ -z "$artist" ]; then
    echo "Could not get track info"
    exit 1
fi

# Create filename in format "Song Name Artist Name"
filename="${track} ${artist}"

# Remove any characters that might cause filesystem issues
filename=$(echo "$filename" | tr '/<>:"|?*' '_')

# Create empty file
touch "$SAVE_DIR/$filename"

echo "Saved: $filename"

# Optional: Send notification
if command -v osascript &> /dev/null; then
    osascript -e "display notification \"$track by $artist\" with title \"Track Saved\" sound name \"Tink\""
fi