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

# Icon definitions
ICON_PLAY="􀊄"            # play.fill
ICON_PAUSE="􀊆"           # pause.fill
ICON_SHUFFLE="􀊝"         # shuffle.on
ICON_REPEAT="􀊞"          # repeat
ICON_TRACK_RADIO="􀑪"     # music.note
ICON_ARTIST_RADIO="􀑫"    # mic.fill  
ICON_ALBUM_RADIO="􁐱"     # record.circle
ICON_PLAYLIST_RADIO="􀑬"  # list.bullet

# File paths
COVER_PATH="/tmp/spotify_cover.jpg"
COMMAND_FILE="/tmp/spotify_command"
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
music_state="context"  # context, track_radio, artist_radio, album_radio, playlist_radio
radio_seed=""  # Store the seed name for radio
radio_toggle_time=0  # Unix timestamp of last radio toggle

# UI/Fetch optimization state
last_cover_url=""
cached_playlist_id=""
cached_playlist_name=""
last_context_uri=""

# API Utility Functions
get_playback_info() {
  $SPOTIFY get key playback 2>/dev/null
}

get_user_playlists() {
  $SPOTIFY get key user-playlists 2>/dev/null
}

get_playlist_by_id() {
  local playlist_id="$1"
  get_user_playlists | jq -r --arg id "$playlist_id" '.[] | select(.id == $id) | .name // ""'
}

# JSON Parsing Utilities
extract_track_info() {
  local json="$1"
  track_id=$(echo "$json" | jq -r '.item.id // ""')
  track_name=$(echo "$json" | jq -r '.item.name // ""')
  track_uri=$(echo "$json" | jq -r '.item.uri // ""')
}

extract_artist_info() {
  local json="$1"
  artist_id=$(echo "$json" | jq -r '.item.artists[0].id // ""')
  artist_name=$(echo "$json" | jq -r '.item.artists[0].name // ""')
}

extract_album_info() {
  local json="$1"
  album_id=$(echo "$json" | jq -r '.item.album.id // ""')
  album_name=$(echo "$json" | jq -r '.item.album.name // ""')
}

extract_context_info() {
  local json="$1"
  context_uri=$(echo "$json" | jq -r '.context.uri // ""')
}

extract_playback_details() {
  local json="$1"
  extract_track_info "$json"
  extract_artist_info "$json"
  extract_album_info "$json"
  extract_context_info "$json"
}

# UI Utility Functions
set_spotify_anchor() {
  local icon="$1"
  local label="$2"
  sketchybar --set spotify.anchor icon="$icon" label="$label"
}

set_spotify_context() {
  local drawing="$1"
  local label="$2"
  if [ -n "$label" ]; then
    sketchybar --set spotify.context drawing="$drawing" label="$label"
  else
    sketchybar --set spotify.context drawing="$drawing"
  fi
}

set_menubar_controls() {
  local icon="$1"
  local color="$2"
  sketchybar --set spotify.menubar_controls icon="$icon" icon.color="$color"
}

# Check if we're currently in Spotify view
is_spotify_view() {
  [ -f "$HOME/.config/sketchybar/.center_state" ] && [ "$(cat "$HOME/.config/sketchybar/.center_state")" -eq 0 ]
}

# Show UI when Spotify is not playing anything
show_stopped_state() {
  set_spotify_anchor ":spotify:" "Not Playing"
  set_spotify_context "off"
  set_menubar_controls "" "$WHITE"
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
  local label="${track:-No Track}"
  sketchybar --set spotify.anchor icon=":spotify:" label="$label"
}

# Update menu bar controls (play/pause button and color)
update_menubar_controls() {
  local controls=""
  
  # Add shuffle if on
  [ "$shuffle_state" = "true" ] && controls="${ICON_SHUFFLE} "
  
  # Add play/pause icon
  if [ "$playing" = "true" ]; then
    controls="${controls}${ICON_PAUSE}"
  else
    controls="${controls}${ICON_PLAY}"
  fi
  
  # Add repeat icon if force-repeat is on
  [ "$is_force_repeat" = "true" ] && controls="${controls} ${ICON_REPEAT}"
  
  # Set color based on state
  local controls_color="$WHITE"
  [ "$playing" = "true" ] && controls_color="$SPOTIFY_GREEN"
  [ "$is_force_repeat" = "true" ] && controls_color="$ORANGE"
  
  sketchybar --set spotify.menubar_controls icon="$controls" icon.color="$controls_color"
}

# Update album artwork
update_artwork() {
  # Only fetch when the cover URL changes and never block the main loop
  if [ -n "$cover_url" ] && [ "$cover_url" != "$last_cover_url" ]; then
    last_cover_url="$cover_url"
    (
      curl -s --max-time 2 "$cover_url" -o "$COVER_PATH" && \
      { \
        if [ -f "$COVER_PATH" ] && sketchybar --query spotify.artwork &>/dev/null; then \
          sketchybar --set spotify.artwork background.image="$COVER_PATH"; \
        fi; \
      }
    ) &
  fi
}

# Update progress bar
update_progress_bar() {
  # Validate inputs
  [ -z "$progress_ms" ] && progress_ms=0
  [ -z "$duration_ms" ] && duration_ms=0
  
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

# Get playlist name from ID
get_playlist_name() {
  local playlist_id="$1"
  # Return cached name if ID hasn't changed
  if [ "$playlist_id" = "$cached_playlist_id" ] && [ -n "$cached_playlist_name" ]; then
    echo "$cached_playlist_name"
    return
  fi

  local name=$(get_playlist_by_id "$playlist_id")
  if [ -n "$name" ]; then
    cached_playlist_id="$playlist_id"
    cached_playlist_name="$name"
    echo "$name"
  else
    echo "Playlist"
  fi
}

# Display normal context (album/artist/playlist)
show_normal_context() {
  local label=""
  
  case "$context_type" in
    "album")    label="$album" ;;
    "artist")   label="$artist" ;;
    "playlist") 
      if [[ "$context_uri" =~ spotify:playlist:(.+) ]]; then
        local playlist_id="${BASH_REMATCH[1]}"
        # If cached ID matches, use cached name without resolving
        if [ "$playlist_id" = "$cached_playlist_id" ] && [ -n "$cached_playlist_name" ]; then
          label="$cached_playlist_name"
        else
          label=$(get_playlist_name "$playlist_id")
        fi
      else
        label="Playlist"
      fi
      ;;
  esac
  
  if [ -n "$label" ]; then
    if is_spotify_view; then
      sketchybar --set spotify.context icon.drawing=off label="$label" drawing=on
    else
      sketchybar --set spotify.context icon.drawing=off label="$label" drawing=off
    fi
  else
    sketchybar --set spotify.context drawing=off
  fi
}

# Display radio mode with icon
show_radio_mode() {
  local radio_icon radio_label
  
  case "$music_state" in
    "track_radio")    radio_icon="$ICON_TRACK_RADIO"; radio_label="Track Radio" ;;
    "artist_radio")   radio_icon="$ICON_ARTIST_RADIO"; radio_label="Artist Radio" ;;
    "album_radio")    radio_icon="$ICON_ALBUM_RADIO"; radio_label="Album Radio" ;;
    "playlist_radio") radio_icon="$ICON_PLAYLIST_RADIO"; radio_label="Playlist Radio" ;;
  esac
  
  local label="${radio_seed} Radio"
  [ -z "$radio_seed" ] && label="$radio_label"
  
  if is_spotify_view; then
    sketchybar --set spotify.context icon="$radio_icon" icon.drawing=on label="$label" drawing=on
  else
    sketchybar --set spotify.context icon="$radio_icon" icon.drawing=on label="$label" drawing=off
  fi
}

# Check if enough time passed to reset radio state
should_reset_radio() {
  [ "$music_state" != "context" ] && [ $(($(date +%s) - radio_toggle_time)) -gt 2 ]
}

# Update context item (playlist/album/radio display)
update_context() {
  if ! sketchybar --query spotify.context &>/dev/null; then
    return
  fi
  
  if [ "$context_type" != "null" ] && [ -n "$context_type" ]; then
    # Context exists: show normal context
    show_normal_context
    
    # Reset radio state if enough time passed
    if should_reset_radio; then
      music_state="context"
      radio_seed=""
      # Radio ended - context restored
    fi
  elif [ "$music_state" != "context" ]; then
    # No context but in radio mode
    echo "$(date): Showing radio mode - state: $music_state, seed: $radio_seed" >&2
    show_radio_mode
  else
    # No context and no radio - hide the item
    sketchybar --set spotify.context drawing=off
  fi
}

# Check and handle force-repeat at track end
check_force_repeat() {
  if [ "$is_force_repeat" = "true" ] && [ "$playing" = "true" ] && [ "$duration_ms" -gt 0 ]; then
    # Check if track is near the end (within last 2 seconds)
    local remaining_ms=$((duration_ms - progress_ms))
    if [ "$remaining_ms" -le 2000 ] && [ "$remaining_ms" -gt 0 ]; then
      # Track is ending and force-repeat is on - restart the track
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
  last_context_uri="$context_uri"
}

update_state_and_ui() {
  # Only update Spotify items if we're in Spotify view (state 0)
  is_spotify_view || return
  
  # Get current playback state
  local playback_json=$(get_playback_info)
  
  if [ -z "$playback_json" ] || [ "$playback_json" = "null" ]; then
    show_stopped_state
    return
  fi
  
  # Parse playback data into global variables
  parse_playback_json "$playback_json"
  
  # Update all UI components
  update_anchor
  update_menubar_controls
  update_artwork
  update_progress_bar
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
    # Starting radio mode
    $SPOTIFY playback start radio --id "$id" "$type"
    music_state=$next_state
    radio_seed="$name"
    radio_toggle_time=$(date +%s)
  fi
}

# Get current track info for adding to playlist
get_current_track_info() {
  local current_playback=$(get_playback_info)
  
  if [ -z "$current_playback" ] || [ "$current_playback" = "null" ]; then
    echo "No track playing"
    return 1
  fi
  
  extract_track_info "$current_playback"
  extract_artist_info "$current_playback"
  
  if [ -z "$track_id" ]; then
    echo "Failed to get track ID"
    return 1
  fi
  
  echo "Track to add: $track_name by $artist_name (ID: $track_id)" >&2
  return 0
}

# Find newest dd-mm-yy playlist
find_newest_daily_playlist() {
  local playlists=$(get_user_playlists)
  
  if [ -z "$playlists" ] || [ "$playlists" = "null" ]; then
    echo "Failed to get playlists" >&2
    return 1
  fi
  
  # Filter playlists matching dd-mm-yy format
  local matching_playlists=$(echo "$playlists" | jq '[.[] | select(.name | test("^[0-9]{2}-[0-9]{2}-[0-9]{2}$")) | {id: .id, name: .name}]')
  
  local playlist_count=$(echo "$matching_playlists" | jq 'length')
  echo "Found $playlist_count playlists matching dd-mm-yy format" >&2
  
  if [ "$playlist_count" -eq 0 ]; then
    echo "No playlists matching dd-mm-yy format found" >&2
    return 1
  fi
  
  echo "All matching playlists:" >&2
  echo "$matching_playlists" | jq -r '.[] | .name' >&2
  
  # Sort playlists by date (newest first)
  local sorted_playlists=$(echo "$matching_playlists" | jq 'sort_by(.name | split("-") | "\(.[2])-\(.[1])-\(.[0])") | reverse')
  
  # Get the newest playlist
  local newest_playlist=$(echo "$sorted_playlists" | jq '.[0]')
  newest_playlist_name=$(echo "$newest_playlist" | jq -r '.name')
  newest_playlist_id=$(echo "$newest_playlist" | jq -r '.id')
  
  echo "Newest playlist: $newest_playlist_name (ID: $newest_playlist_id)" >&2
  return 0
}

# Check if track exists in playlist
check_track_exists_in_playlist() {
  local playlist_id="$1"
  local track_id="$2"
  
  echo "Checking if track already exists in playlist..." >&2
  local playlist_tracks=$($SPOTIFY get item playlist --id "$playlist_id" 2>/dev/null | jq -r '.tracks[].id' 2>/dev/null)
  
  if echo "$playlist_tracks" | grep -q "^${track_id}$"; then
    return 0  # Track exists
  else
    return 1  # Track doesn't exist
  fi
}

# Add track to playlist
add_track_to_playlist() {
  local playlist_id="$1"
  local track_id="$2"
  local track_name="$3"
  local playlist_name="$4"
  
  echo "Adding track to playlist..." >&2
  local add_result=$($SPOTIFY playlist add-track --playlist "$playlist_id" --track "$track_id" 2>&1)
  
  if [ $? -eq 0 ]; then
    echo "Successfully added '$track_name' to playlist '$playlist_name'" >&2
    echo "$add_result" >&2
  else
    echo "Failed to add track to playlist: $add_result" >&2
  fi
}

# Handle adding current track to playlist
handle_add_to_playlist() {
  local track_id track_name artist_name newest_playlist_name newest_playlist_id
  
  # Get current track info
  get_current_track_info || return
  
  # Find newest daily playlist
  find_newest_daily_playlist || return
  
  # Check if track already exists
  if check_track_exists_in_playlist "$newest_playlist_id" "$track_id"; then
    echo "Track '$track_name' already exists in playlist '$newest_playlist_name'" >&2
    return
  fi
  
  # Add track to playlist
  add_track_to_playlist "$newest_playlist_id" "$track_id" "$track_name" "$newest_playlist_name"
}

# Get current playback context for radio toggle
get_radio_context() {
  local current_playback=$(get_playback_info)
  
  if [ -z "$current_playback" ] || [ "$current_playback" = "null" ]; then
    echo "No track playing - cannot start radio"
    return 1
  fi
  
  # Extract all needed info
  extract_playback_details "$current_playback"
  return 0
}

# Handle album radio transition (may go to playlist radio)
handle_album_radio_transition() {
  if [[ "$context_uri" =~ spotify:playlist:(.+) ]]; then
    local playlist_id="${BASH_REMATCH[1]}"
    local playlist_name=$(get_playlist_by_id "$playlist_id")
    [ -z "$playlist_name" ] && playlist_name="Playlist"
    start_radio "$playlist_id" "playlist" "$playlist_name" "playlist_radio"
  else
    start_radio "$track_id" "track" "$track_name" "track_radio"
  fi
}

# Cycle to next radio state
cycle_radio_state() {
  case "$music_state" in
    "context") # normal playback -> track-radio
      start_radio "$track_id" "track" "$track_name" "track_radio"
      ;;
    "track_radio") # track-radio -> artist-radio
      start_radio "$artist_id" "artist" "$artist_name" "artist_radio"
      ;;
    "artist_radio") # artist-radio -> album-radio
      start_radio "$album_id" "album" "$album_name" "album_radio"
      ;;
    "album_radio") # album-radio -> playlist-radio (if in playlist context) or back to track-radio
      handle_album_radio_transition
      ;;
    "playlist_radio") # playlist-radio -> track-radio
      start_radio "$track_id" "track" "$track_name" "track_radio"
      ;;
  esac
}

# Handle radio toggle command - cycle through radio modes
handle_radio_toggle() {
  local track_id track_name artist_id artist_name album_id album_name context_uri
  
  # Get current playback context
  get_radio_context || return
  
  # Cycle to next radio state
  cycle_radio_state
}

# Handle next command with auto-play
handle_next() {
  $SPOTIFY playback next
  # If paused, also start playing
  if [ "$is_playing" != "true" ]; then
    $SPOTIFY playback play-pause
  fi
}

# Handle create daily top tracks command
handle_create_daily_top_tracks() {
  echo "$(date): create-daily-top-tracks command received" >> /tmp/spotify.log
  nohup "$PLUGIN_DIR/create_daily_top_tracks.sh" &
}

# Handle go to top tracks command
handle_go_to_top_tracks() {
  echo "$(date): go-to-top-tracks command received" >> /tmp/spotify.log
  
  # Get all user playlists
  local playlists=$(get_user_playlists)
  if [ -z "$playlists" ]; then
    echo "$(date): Failed to get playlists" >> /tmp/spotify.log
    return
  fi
  
  # Try today's playlist first
  local today=$(date +%Y-%m-%d)
  local today_name="Top Tracks - $today"
  local playlist_id=$(echo "$playlists" | jq -r --arg name "$today_name" '.[] | select(.name == $name) | .id // empty' 2>/dev/null)
  
  # If today's doesn't exist, try yesterday's
  if [ -z "$playlist_id" ]; then
    local yesterday=$(date -d "1 day ago" +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d 2>/dev/null)
    local yesterday_name="Top Tracks - $yesterday"
    playlist_id=$(echo "$playlists" | jq -r --arg name "$yesterday_name" '.[] | select(.name == $name) | .id // empty' 2>/dev/null)
  fi
  
  # Play the playlist if found
  if [ -n "$playlist_id" ]; then
    echo "$(date): Playing top tracks playlist: $playlist_id" >> /tmp/spotify.log
    $SPOTIFY playback start context --id "$playlist_id" playlist
  else
    echo "$(date): No top tracks playlist found for today or yesterday" >> /tmp/spotify.log
  fi
}

handle_command() {
  local cmd="$1"
  
  case "$cmd" in
    "play-pause")   $SPOTIFY playback play-pause ;;
    "next")         handle_next ;;
    "previous")     $SPOTIFY playback previous ;;
    "shuffle")      $SPOTIFY playback shuffle ;;
    "repeat")       is_force_repeat=$([ "$is_force_repeat" = "true" ] && echo false || echo true) ;;
    "radio_toggle") handle_radio_toggle ;;
    "seek-forward") $SPOTIFY playback seek +10000 ;;
    "seek-backward") $SPOTIFY playback seek -10000 ;;
    "add-to-playlist") handle_add_to_playlist ;;
    "create-daily-top-tracks") handle_create_daily_top_tracks ;;
    "go-to-top-tracks") handle_go_to_top_tracks ;;
  esac
}

# Ensure all items are visible when daemon starts
sketchybar --set spotify.anchor drawing=on \
           --set spotify.context drawing=on \
           --set spotify.menubar_controls drawing=on \
           --set spotify.progress drawing=on \
           --set spotify.artwork drawing=on

# Main event loop
while true; do
  # Handle external commands (if any)
  if [ -f "$COMMAND_FILE" ]; then
    handle_command "$(cat "$COMMAND_FILE")"
    rm -f "$COMMAND_FILE"
  fi
  
  # Tick: Update state and UI every iteration
  update_state_and_ui
  
  # Sleep for 0.05 seconds (20 FPS) for snappier updates
  sleep 0.05
done
