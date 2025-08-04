#!/bin/bash

# Path to the daemon-enabled build
# Built with: cargo build --release --no-default-features --features daemon,image,notify,rodio-backend
# The daemon runs in background (spotify_player --daemon) and accepts instant commands
# No special flags needed for client commands - they auto-connect to the daemon
SPOTIFY="/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player"

# Just run the fucking command
case "$1" in
  "play-pause")
    $SPOTIFY playback play-pause
    ;;
  "next")
    $SPOTIFY playback next
    ;;
  "previous")
    $SPOTIFY playback previous
    ;;
esac