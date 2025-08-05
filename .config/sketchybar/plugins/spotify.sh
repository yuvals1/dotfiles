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
  local album=$(echo "$playback_json" | jq -r '.item.album.name // ""')
  local context_type=$(echo "$playback_json" | jq -r '.context.type // ""')
  local context_uri=$(echo "$playback_json" | jq -r '.context.uri // ""')
  
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
  
  # Use global force-repeat state (no file needed)
  
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
  
  # Update context item
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
      # Reset radio state since we have context
      if [ "$radio_state" -ne 0 ]; then
        radio_state=0
        radio_seed=""
        echo "$(date): Radio ended, context restored: $context_type" >> /tmp/spotify_radio.log
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
          radio_icon="􀉩"  # person
          radio_label="Artist Radio"
          ;;
        3) 
          radio_icon="􀑷"  # square.stack
          radio_label="Album Radio"
          ;;
        4) 
          radio_icon="􀋲"  # list.bullet
          radio_label="Playlist Radio"
          ;;
        *) 
          radio_icon="􀑱"  # antenna.radiowaves.left.and.right
          radio_label="Radio"
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
  
  # Check for force-repeat when track is ending
  if [ "$is_force_repeat" = "true" ] && [ "$playing" = "true" ] && [ "$duration_ms" -gt 0 ]; then
    # Check if track is near the end (within last 2 seconds)
    local remaining_ms=$((duration_ms - progress_ms))
    if [ "$remaining_ms" -le 2000 ] && [ "$remaining_ms" -gt 0 ]; then
      # Track is ending and force-repeat is on - restart the track
      echo "$(date): Force-repeat active, restarting track (${remaining_ms}ms remaining)" >> /tmp/spotify_force_repeat.log
      $SPOTIFY playback previous
    fi
  fi
  
  # Store current state
  current_track="$track"
  current_artist="$artist"
  current_album="$album"
  is_playing="$playing"
  last_progress_ms="$progress_ms"
  last_duration_ms="$duration_ms"
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
      # Get current playback info for radio starting
      local current_playback=$($SPOTIFY get key playback 2>/dev/null)
      
      if [ -z "$current_playback" ] || [ "$current_playback" = "null" ]; then
        echo "No track playing - cannot start radio"
        return
      fi
      
      # Parse IDs and names for radio commands
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
          if [ -n "$track_id" ]; then
            echo "$(date): Starting Track Radio for: $track_name" >> /tmp/spotify_radio.log
            $SPOTIFY playback start radio --id "$track_id" track
            radio_state=1
            radio_seed="$track_name"
          fi
          ;;
        1) # track-radio -> artist-radio
          if [ -n "$artist_id" ]; then
            echo "$(date): Starting Artist Radio for: $artist_name" >> /tmp/spotify_radio.log
            $SPOTIFY playback start radio --id "$artist_id" artist
            radio_state=2
            radio_seed="$artist_name"
          fi
          ;;
        2) # artist-radio -> album-radio
          if [ -n "$album_id" ]; then
            echo "$(date): Starting Album Radio for: $album_name" >> /tmp/spotify_radio.log
            $SPOTIFY playback start radio --id "$album_id" album
            radio_state=3
            radio_seed="$album_name"
          fi
          ;;
        3) # album-radio -> playlist-radio (if in playlist context) or back to no-radio
          if [[ "$context_uri" =~ spotify:playlist:(.+) ]]; then
            playlist_id="${BASH_REMATCH[1]}"
            # Get playlist name
            playlist_name=$($SPOTIFY get key user-playlists 2>/dev/null | jq -r --arg id "$playlist_id" '.[] | select(.id == $id) | .name // "Playlist"')
            echo "$(date): Starting Playlist Radio for: $playlist_name" >> /tmp/spotify_radio.log
            $SPOTIFY playback start radio --id "$playlist_id" playlist
            radio_state=4
            radio_seed="$playlist_name"
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
      ;;
    "seek-forward")
      $SPOTIFY playback seek +10
      ;;
    "seek-backward")
      $SPOTIFY playback seek -10
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
