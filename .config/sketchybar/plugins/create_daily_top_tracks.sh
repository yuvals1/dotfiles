#!/bin/bash

# Create daily top tracks playlist
# This script runs in the background to create/update a daily playlist with user's top tracks

# Path to spotify_player binary
SPOTIFY="/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player"

# Playlist name format
TODAY=$(date +%Y-%m-%d)
PLAYLIST_NAME="Top Tracks - $TODAY"

echo "$(date): Starting daily top tracks playlist creation" >> /tmp/spotify_daily_top_tracks.log

# Check if today's playlist already exists
existing_playlists=$($SPOTIFY get key user-playlists 2>/dev/null)
if [ $? -ne 0 ]; then
  echo "$(date): Failed to get user playlists" >> /tmp/spotify_daily_top_tracks.log
  exit 1
fi

# Check if playlist for today already exists
existing_playlist_id=$(echo "$existing_playlists" | jq -r --arg name "$PLAYLIST_NAME" '.[] | select(.name == $name) | .id // empty' 2>/dev/null)

if [ -n "$existing_playlist_id" ]; then
  echo "$(date): Playlist '$PLAYLIST_NAME' already exists (ID: $existing_playlist_id)" >> /tmp/spotify_daily_top_tracks.log
  # Store the playlist ID for the event to use
  echo "$existing_playlist_id" > /tmp/spotify_daily_top_tracks_playlist_id
  exit 0
fi

# Get user's top tracks
echo "$(date): Getting user's top tracks" >> /tmp/spotify_daily_top_tracks.log
top_tracks=$($SPOTIFY get key user-top-tracks 2>/dev/null)
if [ -z "$top_tracks" ]; then
  echo "$(date): Failed to get top tracks" >> /tmp/spotify_daily_top_tracks.log
  exit 1
fi

track_count=$(echo "$top_tracks" | jq 'length' 2>/dev/null)
echo "$(date): Found $track_count top tracks" >> /tmp/spotify_daily_top_tracks.log

# Create the playlist
echo "$(date): Creating playlist: $PLAYLIST_NAME" >> /tmp/spotify_daily_top_tracks.log
create_output=$($SPOTIFY playlist new "$PLAYLIST_NAME" "Daily top tracks playlist - auto-generated" 2>&1)
if [ $? -ne 0 ]; then
  echo "$(date): Failed to create playlist: $create_output" >> /tmp/spotify_daily_top_tracks.log
  exit 1
fi

echo "$(date): Playlist creation output: $create_output" >> /tmp/spotify_daily_top_tracks.log

# Extract playlist ID from output
playlist_id=$(echo "$create_output" | grep -o "spotify:playlist:[^']*" | cut -d':' -f3)
if [ -z "$playlist_id" ]; then
  echo "$(date): Failed to extract playlist ID from output" >> /tmp/spotify_daily_top_tracks.log
  exit 1
fi

echo "$(date): Created playlist ID: $playlist_id" >> /tmp/spotify_daily_top_tracks.log

# Add all top tracks to the playlist
echo "$(date): Adding tracks to playlist..." >> /tmp/spotify_daily_top_tracks.log
track_ids=$(echo "$top_tracks" | jq -r '.[].id' 2>/dev/null)

added_count=0
while IFS= read -r track_id; do
  if [ -n "$track_id" ]; then
    $SPOTIFY playlist add-track --playlist "$playlist_id" --track "$track_id" 2>/dev/null
    if [ $? -eq 0 ]; then
      added_count=$((added_count + 1))
      # Log progress every 50 tracks
      if [ $((added_count % 50)) -eq 0 ]; then
        echo "$(date): Added $added_count tracks..." >> /tmp/spotify_daily_top_tracks.log
      fi
    fi
  fi
done <<< "$track_ids"

echo "$(date): Successfully added $added_count tracks to playlist '$PLAYLIST_NAME'" >> /tmp/spotify_daily_top_tracks.log

# Store the playlist ID for the event to use
echo "$playlist_id" > /tmp/spotify_daily_top_tracks_playlist_id

# Clean up old playlists (keep only last 3 days)
echo "$(date): Cleaning up old top tracks playlists..." >> /tmp/spotify_daily_top_tracks.log
old_playlists=$(echo "$existing_playlists" | jq -r '.[] | select(.name | test("^Top Tracks - [0-9]{4}-[0-9]{2}-[0-9]{2}$")) | select(.name != "'"$PLAYLIST_NAME"'") | .name + ":" + .id' 2>/dev/null)

# Only keep playlists from last 3 days
for i in 1 2 3; do
  keep_date=$(date -d "$i days ago" +%Y-%m-%d 2>/dev/null || date -v-${i}d +%Y-%m-%d 2>/dev/null)
  keep_name="Top Tracks - $keep_date"
  old_playlists=$(echo "$old_playlists" | grep -v "^$keep_name:")
done

# Delete old playlists
echo "$old_playlists" | while IFS=':' read -r name id; do
  if [ -n "$name" ] && [ -n "$id" ]; then
    echo "$(date): Deleting old playlist: $name" >> /tmp/spotify_daily_top_tracks.log
    $SPOTIFY playlist delete "$id" 2>/dev/null
  fi
done

echo "$(date): Daily top tracks playlist creation completed" >> /tmp/spotify_daily_top_tracks.log