#!/bin/bash

# Source colors
CONFIG_DIR="$HOME/.config/sketchybar"
source "$CONFIG_DIR/theme.sh"

# YouTube Music API endpoint
API_URL="http://0.0.0.0:26538/api/v1"
COVER_PATH="/tmp/youtube_music_cover.jpg"
LAST_ARTWORK_URL_FILE="/tmp/youtube_music_last_artwork_url"

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
  
  # Set play/pause icon using SF Symbols
  if [ "$IS_PAUSED" = "true" ]; then
    PLAY_ICON="􀊄"  # play.fill
  else
    PLAY_ICON="􀊆"  # pause.fill
  fi
  
  # Update main display
  sketchybar -m --set youtube_music.anchor label="$CURRENT_SONG"
  
  # Set color based on playing state
  if [ "$IS_PAUSED" = "true" ]; then
    controls_color="$WHITE"  # White when paused
  else
    controls_color="$YOUTUBE_RED"  # YouTube red when playing
  fi
  
  # Update controls with color
  sketchybar -m --set youtube_music.controls icon="$PLAY_ICON" icon.color="$controls_color"
  
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
  
  # Download and update artwork only if URL changed
  if [ -n "$ARTWORK_URL" ] && [ "$ARTWORK_URL" != "null" ]; then
    # Check if artwork URL has changed
    LAST_ARTWORK_URL=""
    if [ -f "$LAST_ARTWORK_URL_FILE" ]; then
      LAST_ARTWORK_URL=$(cat "$LAST_ARTWORK_URL_FILE")
    fi
    
    # Only download if URL changed
    if [ "$ARTWORK_URL" != "$LAST_ARTWORK_URL" ]; then
      # Kill any existing curl processes to prevent conflicts
      pkill -f "curl.*$COVER_PATH" 2>/dev/null
      
      # Download new artwork
      curl -s "$ARTWORK_URL" -o "$COVER_PATH" 2>/dev/null
      
      if [ -f "$COVER_PATH" ] && [ -s "$COVER_PATH" ]; then
        sketchybar -m --set youtube_music.artwork \
          background.image="$COVER_PATH"
        # Store the current URL
        echo "$ARTWORK_URL" > "$LAST_ARTWORK_URL_FILE"
      fi
    fi
  else
    sketchybar -m --set youtube_music.artwork drawing=off
    # Clear the last URL since there's no artwork
    rm -f "$LAST_ARTWORK_URL_FILE" 2>/dev/null
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