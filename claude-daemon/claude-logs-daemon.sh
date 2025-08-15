#!/bin/bash

# Claude logs daemon - runs update-claude-logs.sh every 10 minutes
# Can be interrupted with SIGTERM or SIGINT (Ctrl+C)

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPDATE_SCRIPT="$SCRIPT_DIR/update-claude-logs.sh"
INTERVAL=600  # 10 minutes in seconds
PID_FILE="/tmp/claude-logs-daemon.pid"
LOG_FILE="$HOME/personal/claude-logs/daemon.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Cleanup function
cleanup() {
    log "Daemon shutting down..."
    rm -f "$PID_FILE"
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Check if already running
if [ -f "$PID_FILE" ]; then
    old_pid=$(cat "$PID_FILE")
    if kill -0 "$old_pid" 2>/dev/null; then
        echo "Daemon already running with PID $old_pid"
        exit 1
    else
        echo "Removing stale PID file"
        rm -f "$PID_FILE"
    fi
fi

# Write PID file
echo $$ > "$PID_FILE"

log "Claude logs daemon started (PID: $$)"
log "Update interval: $INTERVAL seconds"

# Main daemon loop
while true; do
    log "Running index update..."
    
    # Run the update script and capture output
    if "$UPDATE_SCRIPT" 2>&1 | while IFS= read -r line; do
        log "  $line"
    done; then
        log "Update completed successfully"
    else
        log "ERROR: Update failed with exit code $?"
    fi
    
    log "Sleeping for $INTERVAL seconds (next run at $(date -d "+$INTERVAL seconds" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -v +${INTERVAL}S '+%Y-%m-%d %H:%M:%S'))"
    
    # Sleep in a way that can be interrupted
    sleep $INTERVAL &
    wait $!
done