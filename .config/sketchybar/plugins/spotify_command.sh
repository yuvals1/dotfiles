#!/bin/bash

# Ultra-lightweight wrapper - "Last Write Wins" approach
# Since we only care about the most recent command, kill any existing ones

SPOTIFY="/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player"
TIMEOUT=5

# Kill ALL existing spotify_player commands except daemon
# This is safe because we only care about the latest state/action
# Note: macOS pkill doesn't support negative lookahead, so we do it differently
for pid in $(pgrep -f "spotify_player"); do
    if ! ps -p "$pid" -o args= | grep -q "daemon"; then
        kill -9 "$pid" 2>/dev/null
    fi
done

# Execute the command with timeout
if command -v gtimeout &> /dev/null; then
    exec gtimeout $TIMEOUT $SPOTIFY "$@"
else
    # Simple fallback
    $SPOTIFY "$@" &
    PID=$!
    
    # Simple timeout
    sleep $TIMEOUT &
    SLEEP_PID=$!
    
    # Wait for either command or timeout to finish
    wait -n $PID $SLEEP_PID 2>/dev/null
    
    # Kill whichever is still running
    kill $PID $SLEEP_PID 2>/dev/null
    
    # Return exit code of spotify command if it finished
    wait $PID 2>/dev/null
fi