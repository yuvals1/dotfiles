#!/bin/bash

# Get the directory of this script
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$PLUGIN_DIR")"

# Source colors
source "$CONFIG_DIR/colors.sh"

# Source radio state functions
source "$CONFIG_DIR/plugins/spotify_radio_state.sh"

# Path to the smart wrapper (prevents hanging processes)
# Set source for proper isolation
export SPOTIFY_SOURCE="display"
SPOTIFY="$CONFIG_DIR/plugins/spotify_command.sh"
COVER_PATH="/tmp/spotify_cover.jpg"
MAX_LABEL_LENGTH=35

truncate_text() {
  local text="$1"
  local max_length=${2:-$MAX_LABEL_LENGTH}
  if [ ${#text} -le "$max_length" ]; then
    echo "$text"
  else
    echo "${text:0:max_length}..."
  fi
}

update() {
  # Get playback info from daemon
  local playback_json=$($SPOTIFY get key playback 2>/dev/null)
  
  if [ -z "$playback_json" ] || [ "$playback_json" = "null" ]; then
    # No playback data - show stopped state with Spotify logo
    sketchybar -m --set spotify.anchor icon=":spotify:" label="Not Playing"
    # Hide context when not playing
    sketchybar -m --set spotify.context drawing=off
    exit 0
  fi
  
  # Parse all data in one pass
  eval "$(echo "$playback_json" | jq -r '
    "is_playing=\(.is_playing)
     track=\"\(.item.name // "")\"  
     artist=\"\(.item.artists[0].name // "")\"
     album=\"\(.item.album.name // "")\"
     cover_url=\"\(.item.album.images[1].url // "")\"
     shuffle_state=\(.shuffle_state)
     repeat_state=\"\(.repeat_state)\"
     progress_ms=\(.progress_ms // 0)
     duration_ms=\(.item.duration_ms // 0)
     context_type=\"\(.context.type // "")\"
     context_uri=\"\(.context.uri // "")\""
  ')"
  
  # Set main icon based on playing state
  if [ "$is_playing" = "true" ]; then
    main_icon="􀊄"
    play_icon="􀊆"
  else
    main_icon="􀊆"
    play_icon="􀊄"
  fi
  
  # Format time display
  if [ "$duration_ms" -gt 0 ] && [ "$is_playing" = "true" -o "$is_playing" = "false" ]; then
    progress_sec=$(( progress_ms / 1000 ))
    duration_sec=$(( duration_ms / 1000 ))
    progress_min=$(( progress_sec / 60 ))
    progress_sec=$(( progress_sec % 60 ))
    duration_min=$(( duration_sec / 60 ))
    duration_sec=$(( duration_sec % 60 ))
    time_display="$(printf "%02d:%02d/%02d:%02d" $progress_min $progress_sec $duration_min $duration_sec)"
  else
    time_display=""
  fi
  
  # Update main display (always show Spotify logo with track title)
  if [ -n "$track" ]; then
    sketchybar -m --set spotify.anchor icon=":spotify:" label="$track"
  else
    sketchybar -m --set spotify.anchor icon=":spotify:" label="No Track"
  fi
  
  # Get current radio state
  radio_state=$(get_radio_state)
  radio_seed=$(get_radio_seed)
  
  # Check if we're starting radio (within 5 seconds)
  is_starting=false
  if [ -f "$HOME/.config/sketchybar/.spotify_radio_starting" ]; then
    is_starting=true
  fi
  
  # Check if we recently cycled radio modes (within 5 seconds)
  recently_cycled=false
  if [ -f "$HOME/.config/sketchybar/.spotify_radio_cycling" ]; then
    cycle_time=$(cat "$HOME/.config/sketchybar/.spotify_radio_cycling")
    current_time=$(date +%s)
    time_diff=$((current_time - cycle_time))
    if [ "$time_diff" -lt 5 ]; then
      recently_cycled=true
    else
      # Protection expired, clear the flag
      rm -f "$HOME/.config/sketchybar/.spotify_radio_cycling"
    fi
  fi
  
  # Validate radio state
  if [ "$radio_state" -ne 0 ]; then
    # We think we're in radio mode - validate this
    if [ -n "$context_type" ] && [ -n "$context_uri" ]; then
      # We have a specific context (playlist/album) - not radio!
      if [ "$recently_cycled" = false ]; then
        # Protection expired, reset immediately
        echo "$(date): Context detected ($context_type) - resetting radio state" >> /tmp/spotify_radio_debug.log
        reset_radio_state
        radio_state=0
        radio_seed=""
        is_starting=false
        rm -f "$HOME/.config/sketchybar/.spotify_radio_starting"
      fi
    elif [ -z "$context_type" ] && [ "$is_starting" = true ]; then
      # No context and we're starting - radio might be loading
      # Check if enough time has passed
      if [ "$recently_cycled" = false ]; then
        # Too much time has passed, radio probably failed
        rm -f "$HOME/.config/sketchybar/.spotify_radio_starting"
        is_starting=false
      fi
    elif [ -z "$context_type" ] && [ "$is_starting" = false ]; then
      # No context and not starting - we're in radio!
      # All good, keep the state
      :
    elif [ -z "$context_type" ] && [ "$is_starting" = true ] && [ "$recently_cycled" = true ]; then
      # No context, still within protection window - might be transitioning
      # Keep showing starting state
      :
    fi
  fi
  
  # Update context item
  if sketchybar --query spotify.context &>/dev/null; then
    if [ "$radio_state" -ne 0 ]; then
      # Radio mode: show radio type with icon
      # Set icon based on radio type
      case "$radio_state" in
        1) radio_icon="􀑪" ;;  # music.note - Track Radio
        2) radio_icon="􀉩" ;;  # person - Artist Radio
        3) radio_icon="􀑷" ;;  # square.stack - Album Radio
        4) radio_icon="􀋲" ;;  # list.bullet - Playlist Radio
        *) radio_icon="􀑱" ;;  # antenna.radiowaves.left.and.right - Generic Radio
      esac
      
      if [ "$is_starting" = true ]; then
        # Show loading state
        if [ -n "$radio_seed" ]; then
          sketchybar -m --set spotify.context icon="􀖇" icon.drawing=on label="Starting ${radio_seed} Radio..." drawing=on
        else
          radio_label=$(get_radio_label "$radio_state")
          sketchybar -m --set spotify.context icon="􀖇" icon.drawing=on label="Starting $radio_label..." drawing=on
        fi
      elif [ -n "$radio_seed" ]; then
        # Show seed name with "Radio" suffix and icon
        sketchybar -m --set spotify.context icon="$radio_icon" icon.drawing=on label="${radio_seed} Radio" drawing=on
      else
        # Show generic radio label with icon
        radio_label=$(get_radio_label "$radio_state")
        sketchybar -m --set spotify.context icon="$radio_icon" icon.drawing=on label="$radio_label" drawing=on
      fi
    else
      # Normal mode: show context without icon
      case "$context_type" in
        "album")
          sketchybar -m --set spotify.context icon.drawing=off label="$album" drawing=on
          ;;
        "artist")
          sketchybar -m --set spotify.context icon.drawing=off label="$artist" drawing=on
          ;;
        "playlist")
          # Extract playlist ID from URI
          if [[ "$context_uri" =~ spotify:playlist:(.+) ]]; then
            playlist_id="${BASH_REMATCH[1]}"
            # Get playlist name
            playlist_name=$($SPOTIFY get key user-playlists 2>/dev/null | jq -r --arg id "$playlist_id" '.[] | select(.id == $id) | .name // ""')
            if [ -n "$playlist_name" ]; then
              sketchybar -m --set spotify.context icon.drawing=off label="$playlist_name" drawing=on
            else
              sketchybar -m --set spotify.context icon.drawing=off label="Playlist" drawing=on
            fi
          else
            sketchybar -m --set spotify.context icon.drawing=off label="Playlist" drawing=on
          fi
          ;;
        *)
          # No context - hide the item
          sketchybar -m --set spotify.context drawing=off
          ;;
      esac
    fi
  fi
  
  # Update menu bar controls
  if sketchybar --query spotify.menubar_controls &>/dev/null; then
    # Build control string with force-repeat indicator
    controls=""
    
    # Add shuffle if on
    if [ "$shuffle_state" = "true" ]; then
      controls="${controls}􀊝 "  # shuffle.on
    fi
    
    # Always show play/pause
    if [ "$is_playing" = "true" ]; then
      controls="${controls}􀊆 "  # pause.fill
    else
      controls="${controls}􀊄 "  # play.fill
    fi
    
    # Add force-repeat icon if active
    if [ -f "$HOME/.config/sketchybar/.force_repeat" ]; then
      controls="${controls}􀊞"  # repeat icon
    fi
    
    # Set color based on playing state and force-repeat
    if [ "$is_playing" = "true" ] && [ -f "$HOME/.config/sketchybar/.force_repeat" ]; then
      controls_color="$ORANGE"  # Orange when playing with force-repeat
    elif [ "$is_playing" = "true" ]; then
      controls_color="$SPOTIFY_GREEN"  # Green when playing
    else
      controls_color="$WHITE"  # White when paused
    fi
    
    sketchybar -m --set spotify.menubar_controls icon="$controls" icon.color="$controls_color"
  fi
  
  # Update playback progress
  if [ "$duration_ms" -gt 0 ]; then
    percentage=$(( progress_ms * 100 / duration_ms ))
    progress_sec=$(( progress_ms / 1000 ))
    duration_sec=$(( duration_ms / 1000 ))
    progress_min=$(( progress_sec / 60 ))
    progress_sec=$(( progress_sec % 60 ))
    duration_min=$(( duration_sec / 60 ))
    duration_sec=$(( duration_sec % 60 ))
    
    # Update menu bar progress if it exists
    if sketchybar --query spotify.progress &>/dev/null; then
      sketchybar -m --set spotify.progress \
        icon="$(printf "%d:%02d" $progress_min $progress_sec)" \
        label="$(printf "%d:%02d" $duration_min $duration_sec)" \
        slider.percentage=$percentage
    fi
  fi
  
  # Smart polling: adjust update frequency based on play state
  if [ "$is_playing" = "true" ]; then
    # Update every second when playing
    sketchybar --set spotify.progress update_freq=1
  else
    # Update every 30 seconds when paused (or only on events)
    sketchybar --set spotify.progress update_freq=30
  fi
  
  # Download cover in background
  if [ -n "$cover_url" ]; then
    curl -s --max-time 2 "$cover_url" -o "$COVER_PATH" &
    wait
    if [ -f "$COVER_PATH" ]; then
      # Update menu bar artwork if it exists
      if sketchybar --query spotify.artwork &>/dev/null; then
        sketchybar -m --set spotify.artwork background.image="$COVER_PATH"
      fi
    fi
  fi
}

# Always update regardless of sender
update