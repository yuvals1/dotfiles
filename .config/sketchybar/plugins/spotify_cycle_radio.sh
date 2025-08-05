#!/bin/bash

# Source radio state functions
source "$HOME/.config/sketchybar/plugins/spotify_radio_state.sh"

# Path to spotify-player
SPOTIFY="/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player"

# Get current state
current_state=$(get_radio_state)

# Calculate next state (0->1->2->3->4->0)
next_state=$(( (current_state + 1) % 5 ))

# Skip playlist radio if not playing from a playlist
if [ "$next_state" -eq 4 ]; then
    # Check if we're playing from a playlist
    playback_json=$($SPOTIFY get key playback 2>/dev/null)
    context_uri=$(echo "$playback_json" | jq -r '.context.uri // ""')
    if [[ ! "$context_uri" =~ spotify:playlist: ]]; then
        # Skip to state 0
        next_state=0
    fi
fi

# Set the new state
set_radio_state "$next_state"

# Set a flag to indicate we just cycled (expires after 30 seconds)
if [ "$next_state" -ne 0 ]; then
    date +%s > "$HOME/.config/sketchybar/.spotify_radio_cycling"
fi

# Log for debugging
echo "Radio state: $current_state -> $next_state ($(get_radio_label $next_state))"

# Trigger sketchybar update to show new state
sketchybar --trigger spotify_update

# Path to spotify-player
SPOTIFY="/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player"

# Handle state transitions
if [ "$next_state" -eq 0 ]; then
    # Returning to normal playback - no action needed
    echo "Returned to normal playback"
    # Clear the cycling flag
    rm -f "$HOME/.config/sketchybar/.spotify_radio_cycling"
else
    # Get current track info for radio seed
    playback_json=$($SPOTIFY get key playback 2>/dev/null)
    
    if [ -z "$playback_json" ] || [ "$playback_json" = "null" ]; then
        echo "No track playing - cannot start radio"
        # Reset state back since we can't start radio
        set_radio_state "$current_state"
        exit 1
    fi
    
    # Parse track info
    track_id=$(echo "$playback_json" | jq -r '.item.id // ""')
    track_name=$(echo "$playback_json" | jq -r '.item.name // ""')
    artist_id=$(echo "$playback_json" | jq -r '.item.artists[0].id // ""')
    artist_name=$(echo "$playback_json" | jq -r '.item.artists[0].name // ""')
    album_id=$(echo "$playback_json" | jq -r '.item.album.id // ""')
    album_name=$(echo "$playback_json" | jq -r '.item.album.name // ""')
    context_uri=$(echo "$playback_json" | jq -r '.context.uri // ""')
    
    # Start appropriate radio type
    case "$next_state" in
        1)  # Track Radio
            if [ -n "$track_id" ]; then
                echo "Starting Track Radio for: $track_name"
                set_radio_seed "$track_name"
                $SPOTIFY playback start radio --id "$track_id" track
            else
                echo "No track ID available"
                set_radio_state "$current_state"
                exit 1
            fi
            ;;
        2)  # Artist Radio
            if [ -n "$artist_id" ]; then
                echo "Starting Artist Radio for: $artist_name"
                set_radio_seed "$artist_name"
                $SPOTIFY playback start radio --id "$artist_id" artist
            else
                echo "No artist ID available"
                set_radio_state "$current_state"
                exit 1
            fi
            ;;
        3)  # Album Radio
            if [ -n "$album_id" ]; then
                echo "Starting Album Radio for: $album_name"
                set_radio_seed "$album_name"
                $SPOTIFY playback start radio --id "$album_id" album
            else
                echo "No album ID available"
                set_radio_state "$current_state"
                exit 1
            fi
            ;;
        4)  # Playlist Radio
            # Extract playlist ID from context URI if it's a playlist
            if [[ "$context_uri" =~ spotify:playlist:(.+) ]]; then
                playlist_id="${BASH_REMATCH[1]}"
                # Get playlist name
                playlist_name=$($SPOTIFY get key user-playlists 2>/dev/null | jq -r --arg id "$playlist_id" '.[] | select(.id == $id) | .name // ""')
                if [ -z "$playlist_name" ]; then
                    playlist_name="Playlist"
                fi
                echo "Starting Playlist Radio for: $playlist_name"
                set_radio_seed "$playlist_name"
                $SPOTIFY playback start radio --id "$playlist_id" playlist
            else
                echo "Not playing from a playlist - cannot start playlist radio"
                set_radio_state "$current_state"
                exit 1
            fi
            ;;
    esac
fi