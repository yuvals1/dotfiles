#!/bin/bash

# Path to the daemon-enabled build
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