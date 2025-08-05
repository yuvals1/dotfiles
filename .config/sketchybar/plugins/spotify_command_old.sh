#!/bin/bash

# Defensive wrapper for spotify-player commands
# Prevents hanging processes and enforces timeouts

SPOTIFY="/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player"
TIMEOUT=5  # 5 second timeout (daemon takes ~4-5s currently)
DEBUG_LOG="/tmp/spotify_command_debug.log"

# Function to log debug info
debug_log() {
    if [ -n "$DEBUG" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$DEBUG_LOG"
    fi
}

# Clean up any existing hanging processes
cleanup_existing() {
    # Kill ALL spotify_player client processes older than 10 seconds
    # This is aggressive but necessary to prevent accumulation
    local current_pid=$$
    for pid in $(pgrep -f "spotify_player" 2>/dev/null); do
        # Skip the daemon and current process
        if [[ "$pid" == "$current_pid" ]] || ps -p "$pid" -o args= | grep -q "daemon"; then
            continue
        fi
        
        # Get process age in seconds (etimes not available on macOS, use etime)
        local etime=$(ps -p "$pid" -o etime= 2>/dev/null | tr -d ' ')
        if [[ -n "$etime" ]]; then
            # Convert etime to seconds (format: [[DD-]HH:]MM:SS)
            local age=0
            if [[ "$etime" =~ ^([0-9]+)-([0-9]+):([0-9]+):([0-9]+)$ ]]; then
                # DD-HH:MM:SS
                age=$((${BASH_REMATCH[1]}*86400 + ${BASH_REMATCH[2]}*3600 + ${BASH_REMATCH[3]}*60 + ${BASH_REMATCH[4]}))
            elif [[ "$etime" =~ ^([0-9]+):([0-9]+):([0-9]+)$ ]]; then
                # HH:MM:SS
                age=$((${BASH_REMATCH[1]}*3600 + ${BASH_REMATCH[2]}*60 + ${BASH_REMATCH[3]}))
            elif [[ "$etime" =~ ^([0-9]+):([0-9]+)$ ]]; then
                # MM:SS
                age=$((${BASH_REMATCH[1]}*60 + ${BASH_REMATCH[2]}))
            fi
            
            if [[ "$age" -gt 10 ]]; then
                debug_log "Killing old process: PID=$pid, age=${age}s"
                kill -9 "$pid" 2>/dev/null
            fi
        fi
    done
}

# Main execution
main() {
    local cmd="$*"
    debug_log "Executing: $cmd"
    
    # Use a lock file to prevent parallel executions for the same command type
    local lock_file="/tmp/spotify_cmd_$(echo "$1" | tr ' /' '__').lock"
    local lock_acquired=false
    
    # Try to acquire lock with timeout
    local count=0
    while [ $count -lt 50 ] && [ "$lock_acquired" = false ]; do
        if mkdir "$lock_file" 2>/dev/null; then
            lock_acquired=true
            debug_log "Lock acquired: $lock_file"
            # Ensure lock is removed on exit
            trap "rmdir '$lock_file' 2>/dev/null" EXIT INT TERM
        else
            sleep 0.1
            count=$((count + 1))
        fi
    done
    
    if [ "$lock_acquired" = false ]; then
        debug_log "Could not acquire lock, skipping command: $cmd"
        return 1
    fi
    
    # Clean up any existing hanging processes
    cleanup_existing
    
    # Check if gtimeout is available (from coreutils on macOS)
    if command -v gtimeout &> /dev/null; then
        # Use gtimeout for reliable timeout
        debug_log "Using gtimeout"
        gtimeout $TIMEOUT $SPOTIFY "$@"
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            debug_log "Command timed out: $cmd"
            echo "Error: spotify_player command timed out" >&2
            return 1
        fi
        return $exit_code
    else
        # Fallback: background process with manual timeout
        debug_log "Using fallback timeout method"
        $SPOTIFY "$@" &
        local pid=$!
        
        # Wait for command to complete or timeout
        local count=0
        while [ $count -lt $((TIMEOUT * 10)) ]; do
            if ! kill -0 $pid 2>/dev/null; then
                # Process finished
                wait $pid
                return $?
            fi
            sleep 0.1
            count=$((count + 1))
        done
        
        # Timeout reached, kill the process
        debug_log "Command timed out (fallback): $cmd"
        kill -9 $pid 2>/dev/null
        echo "Error: spotify_player command timed out" >&2
        return 1
    fi
}

# Execute with all arguments
main "$@"