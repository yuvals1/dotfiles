#!/bin/bash

# Stop the Claude logs daemon

PID_FILE="/tmp/claude-logs-daemon.pid"

if [ ! -f "$PID_FILE" ]; then
    echo "Daemon is not running (no PID file found)"
    exit 1
fi

pid=$(cat "$PID_FILE")

if kill -0 "$pid" 2>/dev/null; then
    echo "Stopping daemon (PID: $pid)..."
    kill "$pid"
    
    # Wait for it to stop
    count=0
    while kill -0 "$pid" 2>/dev/null && [ $count -lt 10 ]; do
        sleep 1
        count=$((count + 1))
    done
    
    if kill -0 "$pid" 2>/dev/null; then
        echo "Daemon did not stop gracefully, forcing..."
        kill -9 "$pid"
    fi
    
    echo "Daemon stopped"
else
    echo "Daemon is not running (process $pid not found)"
    rm -f "$PID_FILE"
fi