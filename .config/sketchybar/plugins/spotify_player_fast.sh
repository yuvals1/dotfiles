#!/bin/bash

PLUGIN_DIR="$HOME/.config/sketchybar/plugins"
SPOTIFY_DISPLAY_CONTROLS="${1:-false}"
COVER_PATH="/tmp/spotify_cover.jpg"
MAX_LABEL_LENGTH=35

# Cache the JSON to avoid multiple calls
PLAYBACK_JSON=""

get_playback() {
  if [ -z "$PLAYBACK_JSON" ]; then
    PLAYBACK_JSON=$(spotify_player get key playback 2>/dev/null)
  fi
  echo "$PLAYBACK_JSON"
}

next () {
  spotify_player playback next &
  # Optimistic update - show loading
  sketchybar -m --set spotify.anchor label="Loading..." &
  # Update after a short delay
  ( sleep 0.8 && update ) &
}

back () {
  spotify_player playback previous &
  sketchybar -m --set spotify.anchor label="Loading..." &
  ( sleep 0.8 && update ) &
}

play () {
  # Get current state for optimistic update
  local current_json=$(get_playback)
  local is_playing=$(echo "$current_json" | jq -r '.is_playing')
  
  # Update icon optimistically
  if [ "$is_playing" = "true" ]; then
    sketchybar -m --set spotify.anchor icon="􀊆" &
  else
    sketchybar -m --set spotify.anchor icon="􀊄" &
  fi
  
  # Execute command
  spotify_player playback play-pause &
}

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
  # Clear cache for fresh data
  PLAYBACK_JSON=""
  
  local playback_json=$(get_playback)
  
  if [ -z "$playback_json" ] || [ "$playback_json" = "null" ]; then
    sketchybar -m --set spotify.anchor drawing=off popup.drawing=off
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
     repeat_state=\"\(.repeat_state)\""
  ')"
  
  if [ "$is_playing" != "true" ] && [ "$is_playing" != "false" ]; then
    sketchybar -m --set spotify.anchor drawing=off popup.drawing=off
    exit 0
  fi
  
  # Set icons
  if [ "$is_playing" = "true" ]; then
    main_icon="􀊄"
    play_icon="􀊆"
  else
    main_icon="􀊆"
    play_icon="􀊄"
  fi
  
  # Download cover in background
  if [ -n "$cover_url" ]; then
    curl -s --max-time 2 "$cover_url" -o "$COVER_PATH" &
  fi
  
  # Update UI immediately
  sketchybar -m --set spotify.anchor icon="$main_icon" label="$track" drawing=on
  
  # Update popup items
  sketchybar -m \
    --set spotify.title label="$(truncate_text "$track" 25)" \
    --set spotify.artist label="$(truncate_text "$artist")" \
    --set spotify.album label="$(truncate_text "$album")"
  
  # Update controls if enabled
  if [ "$SPOTIFY_DISPLAY_CONTROLS" = "true" ]; then
    [ "$shuffle_state" = "true" ] && shuffle="on" || shuffle="off"
    [ "$repeat_state" != "off" ] && repeat="on" || repeat="off"
    
    sketchybar -m \
      --set spotify.shuffle icon.highlight=$shuffle \
      --set spotify.repeat icon.highlight=$repeat \
      --set spotify.play icon="$play_icon"
  fi
  
  # Wait for cover download and update
  wait
  [ -f "$COVER_PATH" ] && sketchybar -m --set spotify.cover background.image="$COVER_PATH"
}

# Simplified event handling
case "$SENDER" in
  "mouse.clicked")
    case "$NAME" in
      "spotify.next") next ;;
      "spotify.back") back ;;
      "spotify.play") play ;;
      *) exit ;;
    esac
    ;;
  "mouse.entered") 
    sketchybar -m --set spotify.anchor popup.drawing=on
    update
    ;;
  "mouse.exited"|"mouse.exited.global") 
    sketchybar -m --set spotify.anchor popup.drawing=off
    ;;
  *) update ;;
esac