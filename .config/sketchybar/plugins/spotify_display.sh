#!/bin/bash

# Path to the daemon-enabled spotify_player binary
SPOTIFY="/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player"
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
     duration_ms=\(.item.duration_ms // 0)"
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
  
  # Update menu bar controls
  if sketchybar --query spotify.menubar_controls &>/dev/null; then
    # Build control string with only active states
    controls=""
    
    # Add shuffle if on
    if [ "$shuffle_state" = "true" ]; then
      controls="${controls}🔀 "
    fi
    
    # Add repeat if on
    case "$repeat_state" in
      "track")
        controls="${controls}🔂 "
        ;;
      "context")
        controls="${controls}🔁 "
        ;;
    esac
    
    # Always show play/pause
    if [ "$is_playing" = "true" ]; then
      controls="${controls}⏸️"
    else
      controls="${controls}▶️"
    fi
    
    sketchybar -m --set spotify.menubar_controls icon="$controls"
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