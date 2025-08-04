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
    # No playback data - show stopped state
    sketchybar -m --set spotify.anchor icon="􀊆" label="Not Playing"
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
  
  # Update main display
  if [ -n "$track" ]; then
    sketchybar -m --set spotify.anchor icon="$main_icon" label="$track"
  else
    sketchybar -m --set spotify.anchor icon="$main_icon" label="No Track"
  fi
  
  # Update popup items
  sketchybar -m \
    --set spotify.title label="$(truncate_text "$track" 25)" \
    --set spotify.artist label="$(truncate_text "$artist")" \
    --set spotify.album label="$(truncate_text "$album")"
  
  # Update playback progress
  if [ "$duration_ms" -gt 0 ]; then
    percentage=$(( progress_ms * 100 / duration_ms ))
    progress_sec=$(( progress_ms / 1000 ))
    duration_sec=$(( duration_ms / 1000 ))
    progress_min=$(( progress_sec / 60 ))
    progress_sec=$(( progress_sec % 60 ))
    duration_min=$(( duration_sec / 60 ))
    duration_sec=$(( duration_sec % 60 ))
    
    sketchybar -m --set spotify.state \
      icon="$(printf "%02d:%02d" $progress_min $progress_sec)" \
      label="$(printf "%02d:%02d" $duration_min $duration_sec)" \
      slider.percentage=$percentage
  fi
  
  # Update controls if they exist
  if sketchybar --query spotify.shuffle &>/dev/null; then
    [ "$shuffle_state" = "true" ] && shuffle="on" || shuffle="off"
    [ "$repeat_state" != "off" ] && repeat="on" || repeat="off"
    
    sketchybar -m \
      --set spotify.shuffle icon.highlight=$shuffle \
      --set spotify.repeat icon.highlight=$repeat \
      --set spotify.play icon="$play_icon"
  fi
  
  # Download cover in background
  if [ -n "$cover_url" ]; then
    curl -s --max-time 2 "$cover_url" -o "$COVER_PATH" &
    wait
    [ -f "$COVER_PATH" ] && sketchybar -m --set spotify.cover background.image="$COVER_PATH"
  fi
}

# Handle mouse events
case "$SENDER" in
  "mouse.entered") 
    sketchybar -m --set spotify.anchor popup.drawing=on
    ;;
  "mouse.exited"|"mouse.exited.global") 
    sketchybar -m --set spotify.anchor popup.drawing=off
    ;;
  *) 
    update
    ;;
esac