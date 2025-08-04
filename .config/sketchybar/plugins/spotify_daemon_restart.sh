#!/bin/bash

# Path to the daemon-enabled spotify_player binary
SPOTIFY="/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player"
LOG_FILE="/tmp/spotify_daemon_restart.log"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to check if daemon is healthy
check_daemon_health() {
    # Check if daemon process exists
    local daemon_pid=$(pgrep -f "spotify_player --daemon")
    if [ -z "$daemon_pid" ]; then
        return 1
    fi
    
    # Test if daemon responds to requests
    if timeout 2s $SPOTIFY get key playback >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to kill all spotify processes
kill_all_spotify() {
    log "Killing all spotify_player processes..."
    
    # Kill daemon
    pkill -f "spotify_player --daemon"
    
    # Kill stuck client processes
    pkill -f "spotify_player get"
    pkill -f "spotify_player playback"
    
    # Force kill if still running after 2 seconds
    sleep 2
    if pgrep -f spotify_player > /dev/null; then
        log "Force killing remaining processes..."
        pkill -9 -f spotify_player
    fi
    
    # Clean up any socket locks
    rm -f /tmp/spotify_player*.sock 2>/dev/null
    rm -f /tmp/sketchybar_*.lock 2>/dev/null
}

# Function to start daemon
start_daemon() {
    log "Starting spotify_player daemon..."
    
    # Start daemon in background
    $SPOTIFY --daemon >/dev/null 2>&1 &
    
    # Wait for daemon to initialize
    sleep 5
    
    # Verify daemon started
    if pgrep -f "spotify_player --daemon" > /dev/null; then
        log "Daemon started with PID: $(pgrep -f 'spotify_player --daemon')"
        
        # Test daemon responds
        if timeout 2s $SPOTIFY get key playback >/dev/null 2>&1; then
            log "Daemon is responding to requests ✓"
            return 0
        else
            log "ERROR: Daemon started but not responding to requests"
            return 1
        fi
    else
        log "ERROR: Failed to start daemon"
        return 1
    fi
}

# Function to count stuck processes
count_stuck_processes() {
    pgrep -f "spotify_player get" | wc -l | tr -d ' '
}

# Main restart function
restart_daemon() {
    log "=== Spotify Daemon Restart ==="
    
    # Check current status
    if check_daemon_health; then
        log "Daemon is healthy, checking for stuck processes..."
        
        local stuck_count=$(count_stuck_processes)
        if [ "$stuck_count" -gt 5 ]; then
            log "Found $stuck_count stuck processes, forcing restart..."
        else
            log "Daemon is healthy with $stuck_count client processes"
            return 0
        fi
    else
        log "Daemon is unhealthy or not running"
    fi
    
    # Kill everything
    kill_all_spotify
    
    # Wait a bit for cleanup
    sleep 1
    
    # Start fresh daemon
    if start_daemon; then
        log "Daemon restart successful ✓"
        
        # Trigger sketchybar update
        sketchybar --trigger spotify_update 2>/dev/null
        
        return 0
    else
        log "Daemon restart failed ✗"
        return 1
    fi
}

# Handle command line arguments
case "${1:-restart}" in
    "restart")
        restart_daemon
        ;;
    "check")
        if check_daemon_health; then
            echo "Daemon is healthy ✓"
            echo "Stuck processes: $(count_stuck_processes)"
            exit 0
        else
            echo "Daemon is unhealthy ✗"
            exit 1
        fi
        ;;
    "kill")
        kill_all_spotify
        log "All spotify processes killed"
        ;;
    "start")
        if pgrep -f "spotify_player --daemon" > /dev/null; then
            log "Daemon already running"
        else
            start_daemon
        fi
        ;;
    "auto")
        # Auto-restart if unhealthy (for cron/automated use)
        if ! check_daemon_health; then
            restart_daemon
        fi
        ;;
    *)
        echo "Usage: $0 {restart|check|kill|start|auto}"
        echo "  restart - Kill and restart daemon"
        echo "  check   - Check daemon health"
        echo "  kill    - Kill all spotify processes"
        echo "  start   - Start daemon if not running"
        echo "  auto    - Restart only if unhealthy"
        exit 1
        ;;
esac