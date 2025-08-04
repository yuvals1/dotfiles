#!/bin/bash

PLUGIN_DIR="$HOME/.config/sketchybar/plugins"
# Allow override via first arg or env variable
SPOTIFY_DISPLAY_CONTROLS="${1:-false}"
COVER_PATH="/tmp/spotify_cover.jpg"
MAX_LABEL_LENGTH=35

# Optional control functions
next () {
  spotify_player playback next
  sleep 0.5  # Give time for the track to change
  update
}

back () {
  spotify_player playback previous
  sleep 0.5
  update
}

play () {
  spotify_player playback play-pause
  update
}

repeat_toggle () {
  spotify_player playback repeat
  update
}

shuffle_toggle () {
  spotify_player playback shuffle
  update
}

truncate_text() {
  local text="$1"
  local max_length=${2:-$MAX_LABEL_LENGTH}
  if [ ${#text} -le "$max_length" ]; then
    echo "$text"
  else
    echo "${text:0:max_length}" | sed -E 's/\s+[[:alnum:]]*$//' | awk '{$1=$1};1' | sed 's/$/.../'
  fi
}

update() {
  # Get playback info
  local playback_json
  playback_json=$(spotify_player get key playback 2>/dev/null)
  
  if [ -z "$playback_json" ] || [ "$playback_json" = "null" ]; then
    sketchybar -m --set spotify.anchor drawing=off popup.drawing=off
    exit 0
  fi
  
  local is_playing=$(echo "$playback_json" | jq -r '.is_playing')
  
  if [ "$is_playing" != "true" ] && [ "$is_playing" != "false" ]; then
    sketchybar -m --set spotify.anchor drawing=off popup.drawing=off
    exit 0
  fi
  
  # Set play or pause icon depending on state
  local play_icon=""
  local main_icon=""
  if [ "$is_playing" = "true" ]; then
    play_icon="􀊆"  # pause icon for controls
    main_icon="􀊄"  # play icon for main display
  else
    play_icon="􀊄"  # play icon for controls
    main_icon="􀊆"  # pause icon for main display
  fi

  # Get track info
  local track artist album cover_url
  track=$(echo "$playback_json" | jq -r '.item.name // empty')
  artist=$(echo "$playback_json" | jq -r '.item.artists[0].name // empty')
  album=$(echo "$playback_json" | jq -r '.item.album.name // empty')
  cover_url=$(echo "$playback_json" | jq -r '.item.album.images[1].url // empty')  # Medium size
  
  # Get shuffle and repeat states
  local shuffle_state=$(echo "$playback_json" | jq -r '.shuffle_state')
  local repeat_state=$(echo "$playback_json" | jq -r '.repeat_state')
  
  local shuffle="off"
  local repeat="off"
  [ "$shuffle_state" = "true" ] && shuffle="on"
  [ "$repeat_state" != "off" ] && repeat="on"
  
  # Download cover image with fallback (only for popup)
  if [ -n "$cover_url" ] && curl -s --max-time 5 "$cover_url" -o "$COVER_PATH"; then
    sketchybar -m --set spotify.cover background.image="$COVER_PATH" background.color=0x00000000
  else
    # fallback if download fails
    sketchybar -m --set spotify.cover background.image="" background.color=0x00000000
  fi

  # Truncate for popup
  track_truncated=$(truncate_text "$track" $((MAX_LABEL_LENGTH * 7/10)))
  artist_truncated=$(truncate_text "$artist")
  album_truncated=$(truncate_text "$album")
  
  # Update main item with icon and track
  sketchybar -m --set spotify.anchor icon="$main_icon" label="$track" drawing=on
  
  # Update popup items
  sketchybar -m \
    --set spotify.title label="$track_truncated" \
    --set spotify.artist label="$artist_truncated" \
    --set spotify.album label="$album_truncated"
  
  # Only update these if controls are enabled
  if [ "$SPOTIFY_DISPLAY_CONTROLS" = "true" ]; then
    sketchybar -m \
      --set spotify.shuffle icon.highlight=$shuffle \
      --set spotify.repeat icon.highlight=$repeat \
      --set spotify.play icon="$play_icon"
  fi
}

scroll() {
  local playback_json
  playback_json=$(spotify_player get key playback 2>/dev/null)
  
  if [ -z "$playback_json" ] || [ "$playback_json" = "null" ]; then
    return
  fi
  
  local duration_ms=$(echo "$playback_json" | jq -r '.item.duration_ms // 0')
  local progress_ms=$(echo "$playback_json" | jq -r '.progress_ms // 0')
  
  local duration=$((duration_ms / 1000))
  local time=$((progress_ms / 1000))

  sketchybar -m --animate linear 10 \
    --set spotify.state slider.percentage=$((time * 100 / duration)) \
                         icon="$(date -r $time +'%M:%S')" \
                         label="$(date -r $duration +'%M:%S')"
}

scrubbing() {
  local playback_json
  playback_json=$(spotify_player get key playback 2>/dev/null)
  
  if [ -z "$playback_json" ] || [ "$playback_json" = "null" ]; then
    return
  fi
  
  local duration_ms=$(echo "$playback_json" | jq -r '.item.duration_ms // 0')
  local target_ms=$((duration_ms * PERCENTAGE / 100))
  
  spotify_player playback seek $target_ms
  sketchybar -m --set spotify.state slider.percentage=$PERCENTAGE
}

popup() {
  sketchybar -m --set spotify.anchor popup.drawing=$1
}

routine() {
  case "$NAME" in
    "spotify.state") scroll
    ;;
    *) update
    ;;
  esac
}

mouse_clicked () {
  case "$NAME" in
    "spotify.next") next
    ;;
    "spotify.back") back
    ;;
    "spotify.play") play
    ;;
    "spotify.shuffle") shuffle_toggle
    ;;
    "spotify.repeat") repeat_toggle
    ;;
    "spotify.state") scrubbing
    ;;
    *) exit
    ;;
  esac
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  "mouse.entered") 
    popup on
    update
  ;;
  "mouse.exited"|"mouse.exited.global") popup off
  ;;
  "routine") routine
  ;;
  "forced") exit 0
  ;;
  *) update
  ;;
esac