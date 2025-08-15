#!/bin/bash

# Start the Claude logs daemon in the background

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DAEMON_SCRIPT="$SCRIPT_DIR/claude-logs-daemon.sh"
LOG_FILE="$HOME/personal/claude-logs/daemon.log"

# Check if daemon is already running
if [ -f "/tmp/claude-logs-daemon.pid" ]; then
    pid=$(cat /tmp/claude-logs-daemon.pid)
    if kill -0 "$pid" 2>/dev/null; then
        echo "Daemon is already running with PID $pid"
        echo "To stop it, run: $SCRIPT_DIR/stop-daemon.sh"
        exit 1
    fi
fi

echo "Starting Claude logs daemon..."
nohup "$DAEMON_SCRIPT" >> "$LOG_FILE" 2>&1 &
daemon_pid=$!

# Wait a moment to check if it started successfully
sleep 1

if kill -0 "$daemon_pid" 2>/dev/null; then
    echo "Daemon started successfully with PID $daemon_pid"
    echo "Logs: $LOG_FILE"
    echo "To stop: $SCRIPT_DIR/stop-daemon.sh"
else
    echo "Failed to start daemon"
    exit 1
fi