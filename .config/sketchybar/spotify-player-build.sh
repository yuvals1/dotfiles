#!/bin/bash

# Build script for spotify_player with daemon support
# This script builds spotify_player with the required features for the sketchybar integration

set -e  # Exit on error

SPOTIFY_PLAYER_DIR="/Users/yuvalspiegel/dev/spotify-player"
TARGET_BIN="$SPOTIFY_PLAYER_DIR/target/release/spotify_player"

echo "Building spotify_player with daemon support..."
echo "Directory: $SPOTIFY_PLAYER_DIR"

# Check if directory exists
if [ ! -d "$SPOTIFY_PLAYER_DIR" ]; then
    echo "Error: spotify-player directory not found at $SPOTIFY_PLAYER_DIR"
    exit 1
fi

# Change to spotify-player directory
cd "$SPOTIFY_PLAYER_DIR"

# Build with the required features
echo "Running cargo build with daemon features..."
cargo build --release --no-default-features --features daemon,image,notify,rodio-backend

# Check if build succeeded
if [ -f "$TARGET_BIN" ]; then
    echo "Build successful!"
    echo "Binary location: $TARGET_BIN"
    
    # Show binary info
    ls -lh "$TARGET_BIN"
    
    # Copy to system location (remove old and copy new)
    echo -e "\nInstalling to /usr/local/bin/spotify_player..."
    sudo rm -f /usr/local/bin/spotify_player
    sudo cp "$TARGET_BIN" /usr/local/bin/spotify_player
    
    # Verify the copy
    if [ -f "/usr/local/bin/spotify_player" ]; then
        echo "Successfully installed to /usr/local/bin/spotify_player"
        
        # Test the new command
        echo -e "\nTesting playlist add-track command..."
        /usr/local/bin/spotify_player playlist add-track --help || echo "Note: Command may not show help without daemon running"
    else
        echo "Error: Failed to copy to /usr/local/bin"
        exit 1
    fi
else
    echo "Error: Build failed - binary not found"
    exit 1
fi

echo -e "\nBuild complete! You can now restart the spotify daemon."