#!/bin/bash

# Spotify command dispatcher script
# Sends commands to the unified spotify.sh state machine via file communication

COMMAND_FILE="/tmp/spotify_command"

# Validate command argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 {play-pause|next|previous|shuffle|repeat|radio_toggle|radio_1|radio_2|radio_3|seek-forward|seek-backward|add-to-playlist|go-to-top-tracks}"
    echo ""
    echo "Commands:"
    echo "  play-pause       - Toggle play/pause"
    echo "  next             - Skip to next track"
    echo "  previous         - Skip to previous track"
    echo "  shuffle          - Toggle shuffle mode"
    echo "  repeat           - Toggle force-repeat mode"
    echo "  radio_toggle     - Enter/exit radio selection mode"
    echo "  radio_1          - Start track radio (when in selection mode)"
    echo "  radio_2          - Start artist radio (when in selection mode)"
    echo "  radio_3          - Start album radio (when in selection mode)"
    echo "  seek-forward     - Seek forward 10 seconds"
    echo "  seek-backward    - Seek backward 10 seconds"
    echo "  add-to-playlist  - Add current track to newest dd-mm-yy playlist"
    echo "  go-to-top-tracks - Navigate to your top tracks"
    exit 1
fi

COMMAND="$1"

# Validate command
case "$COMMAND" in
    "play-pause"|"next"|"previous"|"shuffle"|"repeat"|"radio_toggle"|"radio_1"|"radio_2"|"radio_3"|"seek-forward"|"seek-backward"|"add-to-playlist"|"go-to-top-tracks")
        # Valid command
        ;;
    *)
        echo "Error: Invalid command '$COMMAND'"
        echo "Valid commands: play-pause, next, previous, shuffle, repeat, radio_toggle, radio_1, radio_2, radio_3, seek-forward, seek-backward, add-to-playlist, go-to-top-tracks"
        exit 1
        ;;
esac

# Send command to state machine
echo "$COMMAND" > "$COMMAND_FILE"

# Optional: Show confirmation
echo "Sent command: $COMMAND"