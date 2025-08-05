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

# Cover art file
COVER_PATH="/tmp/spotify_cover.jpg"

# Command communication file
COMMAND_FILE="/tmp/spotify_command"

# PID file for daemon management
PID_FILE="/tmp/spotify_daemon.pid"

# Check if daemon is already running
if [ -f "$PID_FILE" ]; then
  old_pid=$(cat "$PID_FILE")
  if kill -0 "$old_pid" 2>/dev/null; then
    echo "Spotify daemon already running (PID: $old_pid). Exiting."
    exit 0
  else
    # Stale PID file, remove it
    rm -f "$PID_FILE"
  fi
fi

# Write current PID to file
echo $$ > "$PID_FILE"

# Clean up PID file on exit
trap 'rm -f "$PID_FILE"; exit' INT TERM EXIT

# State variables (will be updated each tick)
current_track=""
current_artist=""
current_album=""
is_playing=""
last_update=""
is_force_repeat=false
last_progress_ms=0
last_duration_ms=0
radio_state=0  # 0=no-radio, 1=track-radio, 2=artist-radio, 3=album-radio
radio_seed=""  # Store the seed name for radio
radio_toggle_time=0  # Unix timestamp of last radio toggle

# Check if we're currently in Spotify view
is_spotify_view() {
  local center_state_file="$HOME/.config/sketchybar/.center_state"
  local current_center_state=0
  if [ -f "$center_state_file" ]; then
    current_center_state=$(cat "$center_state_file")
  fi
  [ "$current_center_state" -eq 0 ]
}

# Show UI when Spotify is not playing anything
show_stopped_state() {
  sketchybar --set spotify.anchor icon=":spotify:" label="Not Playing"
  sketchybar --set spotify.context drawing=off
  sketchybar --set spotify.menubar_controls icon="" icon.color="$WHITE"
}

# Parse playback JSON and set global variables
parse_playback_json() {
  local playback_json="$1"
  
  # Parse basic info
  track=$(echo "$playback_json" | jq -r '.item.name // ""')
  artist=$(echo "$playback_json" | jq -r '.item.artists[0].name // ""')
  playing=$(echo "$playback_json" | jq -r '.is_playing')
  shuffle_state=$(echo "$playback_json" | jq -r '.shuffle_state')
  cover_url=$(echo "$playback_json" | jq -r '.item.album.images[1].url // ""')
  progress_ms=$(echo "$playback_json" | jq -r '.progress_ms // 0')
  duration_ms=$(echo "$playback_json" | jq -r '.item.duration_ms // 0')
  album=$(echo "$playback_json" | jq -r '.item.album.name // ""')
  context_type=$(echo "$playback_json" | jq -r '.context.type // ""')
  context_uri=$(echo "$playback_json" | jq -r '.context.uri // ""')
}

# Update anchor item (track name display)
update_anchor() {
  if [ -n "$track" ]; then
    sketchybar --set spotify.anchor icon=":spotify:" label="$track"
  else
    sketchybar --set spotify.anchor icon=":spotify:" label="No Track"
  fi
}

# Update menu bar controls (play/pause button and color)
update_menubar_controls() {
  local controls=""
  local controls_color=""
  
  # Add shuffle if on
  if [ "$shuffle_state" = "true" ]; then
    controls="${controls}􀊝 "  # shuffle.on
  fi
  
  if [ "$playing" = "true" ] && [ "$is_force_repeat" = "false" ]; then
    # Playing without force-repeat - green SF style without repeat button
    controls="${controls}􀊆"  # pause.fill
    controls_color="$SPOTIFY_GREEN"
  elif [ "$playing" = "true" ] && [ "$is_force_repeat" = "true" ]; then
    # Playing with force-repeat - orange SF style with repeat button
    controls="${controls}􀊆 􀊞"  # pause.fill + repeat
    controls_color="$ORANGE"
  else
    # Not playing - grey
    controls="${controls}􀊄"  # play.fill
    controls_color="$WHITE"
    if [ "$is_force_repeat" = "true" ]; then
      controls="${controls} 􀊞"  # add repeat icon even when paused
    fi
  fi
  
  sketchybar --set spotify.menubar_controls icon="$controls" icon.color="$controls_color"
}

# Update album artwork
update_artwork() {
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
}

# Update progress bar
update_progress_bar() {
  # Calculate progress percentage
  local percentage=0
  if [ "$duration_ms" -gt 0 ]; then
    percentage=$(( (progress_ms * 100) / duration_ms ))
    [ $percentage -gt 100 ] && percentage=100
  fi
  
  # Convert to seconds for display
  local progress_sec=$(( progress_ms / 1000 ))
  local duration_sec=$(( duration_ms / 1000 ))
  local progress_min=$(( progress_sec / 60 ))
  local progress_sec=$(( progress_sec % 60 ))
  local duration_min=$(( duration_sec / 60 ))
  local duration_sec=$(( duration_sec % 60 ))
  
  # Update progress item if it exists
  if sketchybar --query spotify.progress &>/dev/null; then
    sketchybar --set spotify.progress \
      icon="$(printf "%d:%02d" $progress_min $progress_sec)" \
      label="$(printf "%d:%02d" $duration_min $duration_sec)" \
      slider.percentage=$percentage
  fi
}

# Update context item (playlist/album/radio display)
update_context() {
  if sketchybar --query spotify.context &>/dev/null; then
    if [ "$context_type" != "null" ] && [ -n "$context_type" ]; then
      # Context exists: show normal context (overrides radio mode)
      case "$context_type" in
        "album")
          sketchybar --set spotify.context icon.drawing=off label="$album" drawing=on
          ;;
        "artist")
          sketchybar --set spotify.context icon.drawing=off label="$artist" drawing=on
          ;;
        "playlist")
          # Extract playlist ID from URI and get actual name
          if [[ "$context_uri" =~ spotify:playlist:(.+) ]]; then
            playlist_id="${BASH_REMATCH[1]}"
            # Get playlist name from API
            playlist_name=$($SPOTIFY get key user-playlists 2>/dev/null | jq -r --arg id "$playlist_id" '.[] | select(.id == $id) | .name // ""')
            if [ -n "$playlist_name" ]; then
              sketchybar --set spotify.context icon.drawing=off label="$playlist_name" drawing=on
            else
              sketchybar --set spotify.context icon.drawing=off label="Playlist" drawing=on
            fi
          else
            sketchybar --set spotify.context icon.drawing=off label="Playlist" drawing=on
          fi
          ;;
        *)
          # Unknown context type - hide the item
          sketchybar --set spotify.context drawing=off
          ;;
      esac
      # Reset radio state since we have context (but wait 2 seconds after toggle)
      if [ "$radio_state" -ne 0 ]; then
        local current_time=$(date +%s)
        local time_since_toggle=$((current_time - radio_toggle_time))
        if [ "$time_since_toggle" -gt 2 ]; then
          radio_state=0
          radio_seed=""
          echo "$(date): Radio ended, context restored: $context_type" >> /tmp/spotify_radio.log
        fi
      fi
    elif [ "$radio_state" -ne 0 ]; then
      # No context but in radio mode: show radio type with icon
      local radio_icon radio_label
      case "$radio_state" in
        1) 
          radio_icon="􀑪"  # music.note
          radio_label="Track Radio"
          ;;
        2)
          radio_icon="􀑫"  # mic.fill
          radio_label="Artist Radio"
          ;;
        3)
          radio_icon="􁐱"  # record.circle
          radio_label="Album Radio"
          ;;
        4)
          radio_icon="􀑬"  # list.bullet
          radio_label="Playlist Radio"
          ;;
      esac
      
      if [ -n "$radio_seed" ]; then
        # Show seed name with "Radio" suffix and icon
        sketchybar --set spotify.context icon="$radio_icon" icon.drawing=on label="${radio_seed} Radio" drawing=on
      else
        # Show generic radio label with icon
        sketchybar --set spotify.context icon="$radio_icon" icon.drawing=on label="$radio_label" drawing=on
      fi
    else
      # No context and no radio - hide the item
      sketchybar --set spotify.context drawing=off
    fi
  fi
}

# Check and handle force-repeat at track end
check_force_repeat() {
  if [ "$is_force_repeat" = "true" ] && [ "$playing" = "true" ] && [ "$duration_ms" -gt 0 ]; then
    # Check if track is near the end (within last 2 seconds)
    local remaining_ms=$((duration_ms - progress_ms))
    if [ "$remaining_ms" -le 2000 ] && [ "$remaining_ms" -gt 0 ]; then
      # Track is ending and force-repeat is on - restart the track
      echo "$(date): Force-repeat active, restarting track (${remaining_ms}ms remaining)" >> /tmp/spotify_force_repeat.log
      $SPOTIFY playback previous
    fi
  fi
}

# Store current state for next iteration
store_current_state() {
  current_track="$track"
  current_artist="$artist"
  current_album="$album"
  is_playing="$playing"
  last_progress_ms="$progress_ms"
  last_duration_ms="$duration_ms"
}

update_state_and_ui() {
  # Only update Spotify items if we're in Spotify view (state 0)
  if ! is_spotify_view; then
    return
  fi
  
  # Get current playback state
  local playback_json=$($SPOTIFY get key playback 2>/dev/null)
  
  if [ -z "$playback_json" ] || [ "$playback_json" = "null" ]; then
    show_stopped_state
    return
  fi
  
  # Parse playback data into global variables
  parse_playback_json "$playback_json"
  
  # Update main display
  update_anchor
  
  # Update controls
  update_menubar_controls
  
  # Update artwork
  update_artwork
  
  # Update progress bar
  update_progress_bar
  
  # Update context item
  update_context
  
  # Check for force-repeat when track is ending
  check_force_repeat
  
  # Store current state for next iteration
  store_current_state
}

# Start a specific radio type
start_radio() {
  local id="$1"
  local type="$2"
  local name="$3"
  local next_state="$4"
  
  if [ -n "$id" ]; then
    echo "$(date): Starting ${type^} Radio for: $name" >> /tmp/spotify_radio.log
    $SPOTIFY playback start radio --id "$id" "$type"
    radio_state=$next_state
    radio_seed="$name"
    radio_toggle_time=$(date +%s)
  fi
}

# Handle radio toggle command - cycle through radio modes
handle_radio_toggle() {
  # Get current playback info for IDs
  local current_playback=$($SPOTIFY get key playback 2>/dev/null)
  
  if [ -z "$current_playback" ] || [ "$current_playback" = "null" ]; then
    echo "No track playing - cannot start radio"
    return
  fi
  
  # Extract IDs we'll need
  local track_id=$(echo "$current_playback" | jq -r '.item.id // ""')
  local track_name=$(echo "$current_playback" | jq -r '.item.name // ""')
  local artist_id=$(echo "$current_playback" | jq -r '.item.artists[0].id // ""')
  local artist_name=$(echo "$current_playback" | jq -r '.item.artists[0].name // ""')
  local album_id=$(echo "$current_playback" | jq -r '.item.album.id // ""')
  local album_name=$(echo "$current_playback" | jq -r '.item.album.name // ""')
  local context_uri=$(echo "$current_playback" | jq -r '.context.uri // ""')
  
  # Cycle through radio modes: no-radio -> track -> artist -> album -> (playlist) -> no-radio
  case "$radio_state" in
    0) # no-radio -> track-radio
      start_radio "$track_id" "track" "$track_name" 1
      ;;
    1) # track-radio -> artist-radio
      start_radio "$artist_id" "artist" "$artist_name" 2
      ;;
    2) # artist-radio -> album-radio
      start_radio "$album_id" "album" "$album_name" 3
      ;;
    3) # album-radio -> playlist-radio (if in playlist context) or back to no-radio
      if [[ "$context_uri" =~ spotify:playlist:(.+) ]]; then
        local playlist_id="${BASH_REMATCH[1]}"
        # Get playlist name
        local playlist_name=$($SPOTIFY get key user-playlists 2>/dev/null | jq -r --arg id "$playlist_id" '.[] | select(.id == $id) | .name // "Playlist"')
        start_radio "$playlist_id" "playlist" "$playlist_name" 4
      else
        # Skip playlist radio, go back to normal
        radio_state=0
        radio_seed=""
        echo "$(date): Back to normal playback" >> /tmp/spotify_radio.log
      fi
      ;;
    4) # playlist-radio -> no-radio
      radio_state=0
      radio_seed=""
      echo "$(date): Back to normal playback" >> /tmp/spotify_radio.log
      ;;
  esac
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
      # Toggle force-repeat state variable
      if [ "$is_force_repeat" = "true" ]; then
        is_force_repeat=false
      else
        is_force_repeat=true
      fi
      ;;
    "radio_toggle")
      handle_radio_toggle
      ;;
    "seek-forward")
      $SPOTIFY playback seek +10000
      ;;
    "seek-backward")
      $SPOTIFY playback seek -10000
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
