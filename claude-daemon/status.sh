#!/bin/bash

# Check Claude logs daemon status

PID_FILE="/tmp/claude-logs-daemon.pid"
LOG_FILE="$HOME/personal/claude-logs/daemon.log"

echo "=== Claude Logs Daemon Status ==="
echo

# Check if running
if [ -f "$PID_FILE" ]; then
    pid=$(cat "$PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
        echo "✅ Status: RUNNING"
        echo "📍 PID: $pid"
        
        # Get process info
        ps_info=$(ps -p "$pid" -o etime=,rss=,pcpu= 2>/dev/null | xargs)
        if [ -n "$ps_info" ]; then
            elapsed=$(echo "$ps_info" | awk '{print $1}')
            memory=$(echo "$ps_info" | awk '{print $2}')
            cpu=$(echo "$ps_info" | awk '{print $3}')
            echo "⏱️  Uptime: $elapsed"
            echo "💾 Memory: $(( memory / 1024 )) MB"
            echo "🔥 CPU: ${cpu}%"
        fi
        
        # Last activity
        if [ -f "$LOG_FILE" ]; then
            echo
            echo "📝 Last activity:"
            tail -3 "$LOG_FILE" | sed 's/^/   /'
            
            # Next run time
            next_run=$(grep "next run at" "$LOG_FILE" | tail -1 | sed 's/.*next run at //')
            if [ -n "$next_run" ]; then
                echo
                echo "⏰ Next run: $next_run"
            fi
        fi
    else
        echo "❌ Status: NOT RUNNING"
        echo "   (stale PID file exists: $pid)"
    fi
else
    echo "❌ Status: NOT RUNNING"
    echo "   (no PID file found)"
fi

echo
echo "📂 Index files: $(ls -1 ~/personal/claude-logs/*.* 2>/dev/null | wc -l | xargs) conversations"
echo "💾 Log file: $LOG_FILE"