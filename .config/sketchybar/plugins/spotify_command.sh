#!/bin/bash

# Ultra-lightweight wrapper - "Last Write Wins" approach
# Since we only care about the most recent command, kill any existing ones

SPOTIFY="/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player"
TIMEOUT=5

# Kill only spotify_player API commands (not TUI or daemon)
# Only kill if command contains known subcommands
for pid in $(pgrep -f "spotify_player"); do
    args=$(ps -p "$pid" -o args= 2>/dev/null)
    
    # Only kill if it's an API command (contains "get", "playback", "play", "search", etc.)
    if [[ "$args" =~ spotify_player.*(get|playback|play|search|like|playlist|device) ]]; then
        # Don't kill daemon
        if [[ ! "$args" =~ --daemon ]]; then
            kill -9 "$pid" 2>/dev/null
        fi
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