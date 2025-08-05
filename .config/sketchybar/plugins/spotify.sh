#!/bin/bash

# Unified Spotify state machine with infinite loop
# Handles all commands and UI updates in a single process

# Path to spotify_player binary
SPOTIFY="/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player"

# Get script directory for accessing config
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$PLUGIN_DIR")"

# Source colors
source "$CONFIG_DIR/colors.sh"

# Force-repeat state file
FORCE_REPEAT_FILE="$HOME/.config/sketchybar/.force_repeat"

# Cover art file
COVER_PATH="/tmp/spotify_cover.jpg"

# Command communication file
COMMAND_FILE="/tmp/spotify_command"

# State variables (will be updated each tick)
current_track=""
current_artist=""
is_playing=""
last_update=""

update_state_and_ui() {
  # Get current playback state
  local playback_json=$($SPOTIFY get key playback 2>/dev/null)
  
  if [ -z "$playback_json" ] || [ "$playback_json" = "null" ]; then
    # No playback data - show stopped state
    sketchybar --set spotify.anchor icon=":spotify:" label="Not Playing"
    sketchybar --set spotify.context drawing=off
    sketchybar --set spotify.menubar_controls icon="" icon.color="$WHITE"
    return
  fi
  
  # Parse basic info
  local track=$(echo "$playback_json" | jq -r '.item.name // ""')
  local artist=$(echo "$playback_json" | jq -r '.item.artists[0].name // ""')
  local playing=$(echo "$playback_json" | jq -r '.is_playing')
  local shuffle_state=$(echo "$playback_json" | jq -r '.shuffle_state')
  local cover_url=$(echo "$playback_json" | jq -r '.item.album.images[1].url // ""')
  local progress_ms=$(echo "$playback_json" | jq -r '.progress_ms // 0')
  local duration_ms=$(echo "$playback_json" | jq -r '.item.duration_ms // 0')
  
  # Update main display
  if [ -n "$track" ]; then
    sketchybar --set spotify.anchor icon=":spotify:" label="$track"
  else
    sketchybar --set spotify.anchor icon=":spotify:" label="No Track"
  fi
  
  # Update controls based on state
  local controls=""
  local controls_color=""
  
  # Add shuffle if on
  if [ "$shuffle_state" = "true" ]; then
    controls="${controls}􀊝 "  # shuffle.on
  fi
  
  # Check force-repeat state
  local is_repeat=false
  if [ -f "$FORCE_REPEAT_FILE" ]; then
    is_repeat=true
  fi
  
  if [ "$playing" = "true" ] && [ "$is_repeat" = "false" ]; then
    # Playing without repeat - green SF style without repeat button
    controls="${controls}􀊆"  # pause.fill
    controls_color="$SPOTIFY_GREEN"
  elif [ "$playing" = "true" ] && [ "$is_repeat" = "true" ]; then
    # Playing with repeat - orange SF style with repeat button
    controls="${controls}􀊆 􀊞"  # pause.fill + repeat
    controls_color="$ORANGE"
  else
    # Not playing - grey
    controls="${controls}􀊄"  # play.fill
    controls_color="$WHITE"
    if [ "$is_repeat" = "true" ]; then
      controls="${controls} 􀊞"  # add repeat icon even when paused
    fi
  fi
  
  sketchybar --set spotify.menubar_controls icon="$controls" icon.color="$controls_color"
  
  # Download and set album artwork
  if [ -n "$cover_url" ]; then
    # Download cover art in background (with timeout)
    curl -s --max-time 2 "$cover_url" -o "$COVER_PATH" &
    wait
    
    # Update artwork if download succeeded
    if [ -f "$COVER_PATH" ]; then
      if sketchybar --query spotify.artwork &>/dev/null; then
        sketchybar --set spotify.artwork background.image="$COVER_PATH"
      fi
    fi
  fi
  
  # Update progress bar and times
  if [ "$duration_ms" -gt 0 ]; then
    # Calculate percentage for slider
    percentage=$(( progress_ms * 100 / duration_ms ))
    
    # Convert milliseconds to minutes:seconds
    progress_sec=$(( progress_ms / 1000 ))
    duration_sec=$(( duration_ms / 1000 ))
    progress_min=$(( progress_sec / 60 ))
    progress_sec=$(( progress_sec % 60 ))
    duration_min=$(( duration_sec / 60 ))
    duration_sec=$(( duration_sec % 60 ))
    
    # Update progress item if it exists
    if sketchybar --query spotify.progress &>/dev/null; then
      sketchybar --set spotify.progress \
        icon="$(printf "%d:%02d" $progress_min $progress_sec)" \
        label="$(printf "%d:%02d" $duration_min $duration_sec)" \
        slider.percentage=$percentage
    fi
  fi
  
  # Store current state
  current_track="$track"
  current_artist="$artist"
  is_playing="$playing"
}

handle_command() {
  local cmd="$1"
  
  case "$cmd" in
    "play-pause")
      $SPOTIFY playback play-pause
      ;;
    "next")
      $SPOTIFY playback next
      ;;
    "previous")
      $SPOTIFY playback previous
      ;;
    "shuffle")
      $SPOTIFY playback shuffle
      ;;
    "repeat")
      # Toggle force-repeat file
      if [ -f "$FORCE_REPEAT_FILE" ]; then
        rm "$FORCE_REPEAT_FILE"
      else
        touch "$FORCE_REPEAT_FILE"
      fi
      ;;
    "radio_toggle")
      # TODO: Implement radio mode cycling
      echo "Radio toggle not yet implemented"
      ;;
  esac
}

# Main event loop
while true; do
  # Handle external commands (if any)
  if [ -f "$COMMAND_FILE" ]; then
    command=$(cat "$COMMAND_FILE")
    rm "$COMMAND_FILE"
    
    handle_command "$command"
  fi
  
  # Tick: Update state and UI every iteration
  update_state_and_ui
  
  # Sleep for 0.2 seconds (5 FPS)
  sleep 0.2
done