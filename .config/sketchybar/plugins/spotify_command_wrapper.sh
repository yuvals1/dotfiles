#!/bin/bash

# Smart wrapper that only kills commands of the same type from the same source
# Uses PID-based marker files to avoid race conditions

SPOTIFY="/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player"
TIMEOUT=5

# Debug logging
echo "$(date): Wrapper called - SOURCE=$SPOTIFY_SOURCE, CMD=$*, PID=$$" >> /tmp/spotify_wrapper.log

# Identify the source (which script called us)
SOURCE="${SPOTIFY_SOURCE:-unknown}"
if [ "$SOURCE" = "unknown" ]; then
    # Try to detect from parent process
    PARENT_CMD=$(ps -p $PPID -o comm= 2>/dev/null || echo "unknown")
    case "$PARENT_CMD" in
        *display*) SOURCE="display" ;;
        *keyboard*) SOURCE="keyboard" ;;
        *radio*) SOURCE="radio" ;;
        *event*) SOURCE="event" ;;
        *save*) SOURCE="save" ;;
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

# Kill all processes with same source and type
MARKER_PREFIX="${SOURCE}_${COMMAND_TYPE}_"
for marker_file in "$MARKER_DIR"/${MARKER_PREFIX}*; do
    if [ -f "$marker_file" ]; then
        # Extract PID from filename
        old_pid=$(basename "$marker_file" | sed "s/^${MARKER_PREFIX}//")
        if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
            kill -9 "$old_pid" 2>/dev/null
        fi
        # Remove the marker file
        rm -f "$marker_file"
    fi
done

# Execute the command with timeout
if command -v gtimeout &> /dev/null; then
    gtimeout $TIMEOUT $SPOTIFY "$@" &
    PID=$!
else
    $SPOTIFY "$@" &
    PID=$!
    
    # Simple timeout in background
    (
        sleep $TIMEOUT
        kill -9 $PID 2>/dev/null
    ) &
    TIMEOUT_PID=$!
fi

# Create our marker file
MARKER_FILE="$MARKER_DIR/${MARKER_PREFIX}${PID}"
touch "$MARKER_FILE"
echo "$(date): Created marker: ${MARKER_PREFIX}${PID}" >> /tmp/spotify_wrapper.log
echo "$(date): Marker file exists: $([ -f "$MARKER_FILE" ] && echo "YES" || echo "NO")" >> /tmp/spotify_wrapper.log
ls -la "$MARKER_FILE" 2>&1 >> /tmp/spotify_wrapper.log

# Wait for command to finish
wait $PID
EXIT_CODE=$?

# Kill timeout if using fallback
if [ -n "$TIMEOUT_PID" ]; then
    kill $TIMEOUT_PID 2>/dev/null
fi

# Remove our marker file
echo "$(date): Removing marker: ${MARKER_PREFIX}${PID}" >> /tmp/spotify_wrapper.log
rm -f "$MARKER_DIR/${MARKER_PREFIX}${PID}"
echo "$(date): Marker removed, file exists: $([ -f "$MARKER_DIR/${MARKER_PREFIX}${PID}" ] && echo "YES" || echo "NO")" >> /tmp/spotify_wrapper.log

exit $EXIT_CODE