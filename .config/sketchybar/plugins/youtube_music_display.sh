#!/bin/bash

# YouTube Music API endpoint
API_URL="http://0.0.0.0:26538/api/v1"
COVER_PATH="/tmp/youtube_music_cover.jpg"

update() {
  # Get song info from YouTube Music API
  SONG_INFO=$(curl -s "$API_URL/song-info" 2>/dev/null)
  
  if [ -z "$SONG_INFO" ] || [ "$SONG_INFO" = "null" ]; then
    # API not available - just exit without changing drawing state
    exit 0
  fi
  
  # Parse song info
  IS_PAUSED=$(echo "$SONG_INFO" | jq -r '.isPaused')
  TITLE=$(echo "$SONG_INFO" | jq -r '.title // "Unknown"')
  ARTIST=$(echo "$SONG_INFO" | jq -r '.artist // "Unknown"')
  ALBUM=$(echo "$SONG_INFO" | jq -r '.album // "Unknown"')
  ARTWORK_URL=$(echo "$SONG_INFO" | jq -r '.imageSrc // ""')
  
  # Get elapsed time and duration
  ELAPSED_SECONDS=$(echo "$SONG_INFO" | jq -r '.elapsedSeconds // 0')
  DURATION_SECONDS=$(echo "$SONG_INFO" | jq -r '.songDuration // 0')
  
  # Format display
  CURRENT_SONG="${TITLE}"
  
  # Set play/pause icon
  if [ "$IS_PAUSED" = "true" ]; then
    PLAY_ICON="▶️"
  else
    PLAY_ICON="⏸️"
  fi
  
  # Update main display
  sketchybar -m --set youtube_music.anchor label="$CURRENT_SONG"
  
  # Update controls
  sketchybar -m --set youtube_music.controls icon="$PLAY_ICON"
  
  # Update progress if we have duration
  if [ "$DURATION_SECONDS" != "0" ] && [ "$DURATION_SECONDS" != "null" ]; then
    # Calculate percentage
    PERCENTAGE=$(echo "scale=0; $ELAPSED_SECONDS * 100 / $DURATION_SECONDS" | bc)
    
    # Format times
    ELAPSED_MIN=$((ELAPSED_SECONDS / 60))
    ELAPSED_SEC=$((ELAPSED_SECONDS % 60))
    DURATION_MIN=$((DURATION_SECONDS / 60))
    DURATION_SEC=$((DURATION_SECONDS % 60))
    
    sketchybar -m --set youtube_music.progress \
      icon="$(printf "%d:%02d" $ELAPSED_MIN $ELAPSED_SEC)" \
      label="$(printf "%d:%02d" $DURATION_MIN $DURATION_SEC)" \
      slider.percentage="$PERCENTAGE"
  else
    sketchybar -m --set youtube_music.progress drawing=off
  fi
  
  # Download and update artwork
  if [ -n "$ARTWORK_URL" ] && [ "$ARTWORK_URL" != "null" ]; then
    curl -s "$ARTWORK_URL" -o "$COVER_PATH" &
    wait
    if [ -f "$COVER_PATH" ]; then
      sketchybar -m --set youtube_music.artwork \
        background.image="$COVER_PATH"
    fi
  else
    sketchybar -m --set youtube_music.artwork drawing=off
  fi
  
  # Smart polling - faster when playing
  if [ "$IS_PAUSED" = "true" ]; then
    sketchybar --set youtube_music.progress update_freq=5
  else
    sketchybar --set youtube_music.progress update_freq=1
  fi
}

# Always update
update