# Claude Logs Daemon

A bash daemon that indexes Claude Code conversations for easy browsing and searching.

## What it does

- Scans `~/.claude/projects/*/*.jsonl` files every 10 minutes
- Creates index files in `~/personal/claude-logs/`
- Each index file is named: `{num-messages}-{project-dir}-{session-id}`
- Index files are empty (just the filename contains the metadata)

## Files

- `update-claude-logs.sh` - The core script that performs the indexing
- `claude-logs-daemon.sh` - The daemon that runs the update script every 10 minutes
- `start-daemon.sh` - Start the daemon in the background
- `stop-daemon.sh` - Stop the running daemon
- `daemon.log` - Created in `~/personal/claude-logs/` with daemon activity

## Usage

### Start the daemon
```bash
./start-daemon.sh
```

### Stop the daemon
```bash
./stop-daemon.sh
```

### Run update manually (one-time)
```bash
./update-claude-logs.sh
```

### Check daemon status
```bash
# Check if running
if [ -f /tmp/claude-logs-daemon.pid ] && kill -0 $(cat /tmp/claude-logs-daemon.pid) 2>/dev/null; then
    echo "Daemon is running (PID: $(cat /tmp/claude-logs-daemon.pid))"
else
    echo "Daemon is not running"
fi

# View logs
tail -f ~/personal/claude-logs/daemon.log
```

## Index File Format

Example: `8--Users-yuvalspiegel-dev-claude-conncurent-test-0bad5d5f-3fb0-4397-8091-c7bd602b0812`

This represents:
- 8 messages in the conversation
- Project: `/Users/yuvalspiegel/dev/claude-conncurent-test`
- Session ID: `0bad5d5f-3fb0-4397-8091-c7bd602b0812`

## Performance

- Processes ~500 conversations in ~3-5 seconds
- Uses `wc -l` for efficient line counting without loading files into memory
- Removes and recreates all index files on each run for simplicity

## Auto-start on Login (Optional)

To start the daemon automatically on macOS login, create a LaunchAgent:

```bash
# Create the plist file
cat > ~/Library/LaunchAgents/com.claude.logs.daemon.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.claude.logs.daemon</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/yuvalspiegel/dotfiles/claude-daemon/claude-logs-daemon.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/Users/yuvalspiegel/personal/claude-logs/daemon.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/yuvalspiegel/personal/claude-logs/daemon.log</string>
</dict>
</plist>
EOF

# Load the daemon
launchctl load ~/Library/LaunchAgents/com.claude.logs.daemon.plist
```