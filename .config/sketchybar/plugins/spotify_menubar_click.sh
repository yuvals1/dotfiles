#!/bin/bash

# Path to spotify_player
SPOTIFY="/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player"

# Get click position relative to the item
# For now, just toggle play/pause on any click
# TODO: Detect which emoji was clicked based on x position

$SPOTIFY playback play-pause