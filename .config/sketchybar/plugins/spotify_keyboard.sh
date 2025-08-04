#!/bin/bash

# Path to the daemon-enabled build
# Built with: cargo build --release --no-default-features --features daemon,image,notify,rodio-backend
# The daemon runs in background (spotify_player --daemon) and accepts instant commands
# No special flags needed for client commands - they auto-connect to the daemon
SPOTIFY="/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player"

# Handle keyboard shortcuts and control button clicks
case "$1" in
  "play-pause")
    $SPOTIFY playback play-pause
    ;;
  "next")
    $SPOTIFY playback next
    # If paused, also start playing
    if [ "$($SPOTIFY get key playback | jq -r '.is_playing')" = "false" ]; then
      $SPOTIFY playback play-pause
    fi
    ;;
  "previous")
    $SPOTIFY playback previous
    ;;
  *)
    # Handle control button clicks based on NAME
    case "$NAME" in
      "spotify.play")
        $SPOTIFY playback play-pause
        ;;
      "spotify.next")
        $SPOTIFY playback next
        # If paused, also start playing
        if [ "$($SPOTIFY get key playback | jq -r '.is_playing')" = "false" ]; then
          $SPOTIFY playback play-pause
        fi
        ;;
      "spotify.back")
        $SPOTIFY playback previous
        ;;
      "spotify.shuffle")
        $SPOTIFY playback toggle shuffle
        ;;
      "spotify.repeat")
        $SPOTIFY playback toggle repeat
        ;;
    esac
    ;;
esac