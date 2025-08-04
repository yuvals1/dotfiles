#!/bin/bash

# Path to spotify-player
SPOTIFY="/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player"

# Directory with saved songs
SAVE_DIR="$HOME/spotify/songs/current"

# Check if directory exists
if [ ! -d "$SAVE_DIR" ]; then
    echo "No saved songs directory found"
    exit 1
fi

# If a filename is provided as argument, play it
if [ -n "$1" ]; then
    $SPOTIFY playback start track --name "$1"
    exit 0
fi

# Otherwise, list all saved songs
echo "Saved songs:"
ls -1 "$SAVE_DIR" | while read -r filename; do
    echo "  $filename"
done

echo ""
echo "Usage: $0 \"Song Name Artist Name\""
echo "Example: $0 \"Hello Adele\""