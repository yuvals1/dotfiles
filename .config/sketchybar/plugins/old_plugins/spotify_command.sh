#!/bin/bash

# Smart wrapper that only kills commands of the same type from the same source
# Uses PID-based marker files to avoid race conditions

SPOTIFY="/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player"
TIMEOUT=5

# Cache directory
CACHE_DIR="$HOME/.config/sketchybar/.spotify_cache"
mkdir -p "$CACHE_DIR"

# Debug logging
echo "$(date): Wrapper called - SOURCE=$SPOTIFY_SOURCE, CMD=$*, PID=$$" >> /tmp/spotify_wrapper.log

# Identify the source (which script called us)
SOURCE="${SPOTIFY_SOURCE:-unknown}"
if [ "$SOURCE" = "unknown" ]; then
    # Try to detect from parent process command line
    PARENT_CMD=$(ps -p $PPID -o args= 2>/dev/null || echo "unknown")
    case "$PARENT_CMD" in
        *spotify_display*) SOURCE="display" ;;
        *spotify_keyboard*) SOURCE="keyboard" ;;
        *spotify_cycle_radio*) SOURCE="radio" ;;
        *spotify_event*) SOURCE="event" ;;
        *spotify_save*) SOURCE="save" ;;
        *spotify_play_saved*) SOURCE="play_saved" ;;
        *spotify_menubar*) SOURCE="menubar_click" ;;
        *) SOURCE="other" ;;
    esac
fi

# Identify command type from arguments
COMMAND_TYPE="unknown"
if [ $# -gt 0 ]; then
    case "$1" in
        "get")
            if [ "$2" = "key" ]; then
                COMMAND_TYPE="get_$3"  # get_playback, get_user-playlists, etc.
            else
                COMMAND_TYPE="get_other"
            fi
            ;;
        "playback")
            COMMAND_TYPE="playback_$2"  # playback_play-pause, playback_next, etc.
            ;;
        "play")
            COMMAND_TYPE="play"
            ;;
        "search")
            COMMAND_TYPE="search"
            ;;
        *)
            COMMAND_TYPE="$1"
            ;;
    esac
fi

# Marker directory
MARKER_DIR="$HOME/.config/sketchybar/.spotify_markers"
mkdir -p "$MARKER_DIR"

# Kill all processes with same command type (regardless of source)
MARKER_PREFIX="${COMMAND_TYPE}_"
for marker_file in "$MARKER_DIR"/${MARKER_PREFIX}*; do
    if [ -f "$marker_file" ]; then
        # Extract PID from filename
        old_pid=$(basename "$marker_file" | sed "s/^${MARKER_PREFIX}//")
        if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
            kill -9 "$old_pid" 2>/dev/null
            echo "$(date): Killed existing $COMMAND_TYPE process (PID: $old_pid)" >> /tmp/spotify_wrapper.log
        fi
        # Remove the marker file
        rm -f "$marker_file"
    fi
done

# Cache file based on command type
CACHE_FILE="$CACHE_DIR/${COMMAND_TYPE}.json"

# Check if cache exists and is fresh (less than 500ms old)
CACHE_MAX_AGE_MS=500
if [ -f "$CACHE_FILE" ]; then
    # Get file modification time and current time in seconds
    if [[ "$OSTYPE" == "darwin"* ]]; then
        CACHE_MOD_TIME=$(stat -f %m "$CACHE_FILE")
    else
        CACHE_MOD_TIME=$(stat -c %Y "$CACHE_FILE")
    fi
    CURRENT_TIME=$(date +%s)
    
    # Calculate age in seconds (we'll use 1 second as threshold for simplicity)
    AGE_SECONDS=$((CURRENT_TIME - CACHE_MOD_TIME))
    
    # If cache is fresh (less than 1 second old), use it
    if [ "$AGE_SECONDS" -eq 0 ]; then
        echo "$(date): Using cached result for $COMMAND_TYPE (< 1s old)" >> /tmp/spotify_wrapper.log
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Create a temporary file for output
TEMP_OUTPUT=$(mktemp)

# Execute the command with timeout and capture output
if command -v gtimeout &> /dev/null; then
    gtimeout $TIMEOUT $SPOTIFY "$@" > "$TEMP_OUTPUT" 2>&1 &
    PID=$!
else
    $SPOTIFY "$@" > "$TEMP_OUTPUT" 2>&1 &
    PID=$!
    
    # Simple timeout in background
    (
        sleep $TIMEOUT
        kill -9 $PID 2>/dev/null
    ) &
    TIMEOUT_PID=$!
fi

# Flag to track if we were killed
WAS_KILLED=false

# Create our marker file (without source prefix)
MARKER_FILE="$MARKER_DIR/${COMMAND_TYPE}_${PID}"
touch "$MARKER_FILE"
echo "$(date): Created marker: ${COMMAND_TYPE}_${PID} (source: $SOURCE)" >> /tmp/spotify_wrapper.log

# Wait for command to finish
wait $PID
EXIT_CODE=$?

# Check if we were killed (exit code 143 = SIGTERM, 137 = SIGKILL)
if [ $EXIT_CODE -eq 143 ] || [ $EXIT_CODE -eq 137 ]; then
    WAS_KILLED=true
    echo "$(date): Process was killed, will check for cache" >> /tmp/spotify_wrapper.log
fi

# Kill timeout if using fallback
if [ -n "$TIMEOUT_PID" ]; then
    kill $TIMEOUT_PID 2>/dev/null
fi

# Remove our marker file
echo "$(date): Removing marker: ${COMMAND_TYPE}_${PID}" >> /tmp/spotify_wrapper.log
rm -f "$MARKER_FILE"

# If we were killed, wait a bit and check cache
if [ "$WAS_KILLED" = true ]; then
    echo "$(date): Waiting 100ms for cache from winning process..." >> /tmp/spotify_wrapper.log
    sleep 0.1
    
    # Check if cache was updated by the winning process
    if [ -f "$CACHE_FILE" ]; then
        # Get cache age
        if [[ "$OSTYPE" == "darwin"* ]]; then
            CACHE_MOD_TIME=$(stat -f %m "$CACHE_FILE")
        else
            CACHE_MOD_TIME=$(stat -c %Y "$CACHE_FILE")
        fi
        CURRENT_TIME=$(date +%s)
        AGE_SECONDS=$((CURRENT_TIME - CACHE_MOD_TIME))
        
        # If cache is fresh (less than 2 seconds old), use it
        if [ "$AGE_SECONDS" -le 1 ]; then
            echo "$(date): Using fresh cache after being killed" >> /tmp/spotify_wrapper.log
            cat "$CACHE_FILE"
            EXIT_CODE=0
        else
            echo "$(date): Cache too old after being killed" >> /tmp/spotify_wrapper.log
        fi
    fi
else
    # Normal case - output our result
    cat "$TEMP_OUTPUT"
    
    # If command succeeded, update cache
    if [ $EXIT_CODE -eq 0 ] && [ -s "$TEMP_OUTPUT" ]; then
        cp "$TEMP_OUTPUT" "$CACHE_FILE"
        echo "$(date): Cached result to $CACHE_FILE" >> /tmp/spotify_wrapper.log
    fi
fi

# Cleanup temp file
rm -f "$TEMP_OUTPUT"

exit $EXIT_CODE