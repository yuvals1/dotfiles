# Claude Logs Daemon

A bash daemon that indexes Claude Code conversations for easy browsing and resuming.

## What it does

- Scans `~/.claude/projects/*/*.jsonl` files every 10 minutes
- Creates index files in `~/personal/claude-logs/`
- Each index file contains a resume command: `cd {directory} ; claude -r {session-id}`
- Filenames include conversation metadata: age, message count, project name, and parent directory
- Skips summary-only files (conversations without a working directory)

## Files

- `update-claude-logs.sh` - The core script that performs the indexing
- `claude-logs-daemon.sh` - The daemon that runs the update script every 10 minutes
- `start-daemon.sh` - Start the daemon in the background
- `stop-daemon.sh` - Stop the running daemon
- `status.sh` - Check daemon status and statistics
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
./status.sh
```

### View logs
```bash
tail -f ~/personal/claude-logs/daemon.log
```

## Index File Format

Example: `0d-2h num-msg:8 dir-name:claude-conncurent-test parent-dir-path:Users-yuvalspiegel-dev 0bad5d5f-3fb0-4397-8091-c7bd602b0812`

This represents:
- `0d-2h` - 0 days, 2 hours since last modified
- `num-msg:8` - 8 messages in the conversation
- `dir-name:claude-conncurent-test` - Project directory name
- `parent-dir-path:Users-yuvalspiegel-dev` - Parent directory path (dots replaced with underscores)
- `0bad5d5f-3fb0-4397-8091-c7bd602b0812` - Session ID

**File contents:** `cd /Users/yuvalspiegel/dev/claude-conncurent-test ; claude -r 0bad5d5f-3fb0-4397-8091-c7bd602b0812`

## Performance

- Processes ~493 conversations in ~17-18 seconds
- Uses line-by-line reading to find `cwd` field efficiently (stops at first match)
- Skips files without `cwd` field (summary-only files)
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