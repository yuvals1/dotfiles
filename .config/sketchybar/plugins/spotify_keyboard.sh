#!/bin/bash

# Path to the daemon-enabled build
# Built with: cargo build --release --no-default-features --features daemon,image,notify,rodio-backend
# The daemon runs in background (spotify_player --daemon) and accepts instant commands
# No special flags needed for client commands - they auto-connect to the daemon

# Get the directory of this script
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Use the wrapper to prevent hanging processes
SPOTIFY="$PLUGIN_DIR/spotify_command.sh"

# Handle keyboard shortcuts and control button clicks
case "$1" in
  "play-pause")
    $SPOTIFY playback play-pause
    ;;
  "next")
    $SPOTIFY playback next
    # Wait a moment for the track change to register
    sleep 0.3
    # If paused, also start playing
    if [ "$($SPOTIFY get key playback | jq -r '.is_playing')" = "false" ]; then
      $SPOTIFY playback play-pause
    fi
    ;;
  "previous" | "prev")
    $SPOTIFY playback previous
    ;;
  "shuffle")
    $SPOTIFY playback shuffle
    # Trigger immediate update
    sleep 0.2 && sketchybar --trigger spotify_update &
    ;;
  "repeat")
    # Use our force-repeat toggle instead of Spotify's repeat
    /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_toggle_force_repeat.sh
    # No need for sleep since toggle script already triggers update
    ;;
  *)
    # Handle control button clicks based on NAME
    case "$NAME" in
      "spotify.play")
        $SPOTIFY playback play-pause
        ;;
      "spotify.next")
        $SPOTIFY playback next
        # Wait a moment for the track change to register
        sleep 0.3
        # If paused, also start playing
        if [ "$($SPOTIFY get key playback | jq -r '.is_playing')" = "false" ]; then
          $SPOTIFY playback play-pause
        fi
        ;;
      "spotify.back")
        $SPOTIFY playback previous
        ;;
      "spotify.shuffle")
        $SPOTIFY playback shuffle
        # Trigger immediate update
        sleep 0.2 && sketchybar --trigger spotify_update &
        ;;
      "spotify.repeat")
        # Use our force-repeat toggle instead of Spotify's repeat
        /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_toggle_force_repeat.sh
        # No need for sleep since toggle script already triggers update
        ;;
    esac
    ;;
esac