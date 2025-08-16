# Claude Logs Daemon

Indexes Claude Code conversations every 10 minutes for easy browsing and resuming.

## Usage

```bash
./start-daemon.sh    # Start daemon
./stop-daemon.sh     # Stop daemon  
./status.sh          # Check status
./update-claude-logs.sh  # Manual run
```

## What it creates

**Location**: `~/personal/claude-logs/raw-logs/`

**Filename format**: `{age} msg:{count} dir:---{project}--- parent-dir-path:{path} {session-id}`

**Example**: `00d-02h msg:8 dir:---claude-test--- parent-dir-path:Users-dev 0bad5d5f-3fb0`

**File contents**: `cd /Users/dev/claude-test ; claude -r 0bad5d5f-3fb0`
*(Resume command to continue the conversation from its original directory)*

## Performance

Processes ~420 conversations in ~16 seconds. Filters out:
- Summary-only files (no working directory)
- Conversations older than 99 days
- Conversations with less than 10 messages

## Future Considerations

- **Filename length**: Currently ~200 chars (macOS limit: 255). Monitor as paths grow longer.
- **Incremental updates**: Currently recreates all files. Could optimize to only update changed conversations.
- **Special characters**: Handle edge cases in project names beyond dots and slashes.
- **Very large files**: Current line-by-line reading works well, but watch for files with extremely long lines.

## Auto-start (Optional)

```bash
# Create LaunchAgent
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
</dict>
</plist>
EOF

# Load it
launchctl load ~/Library/LaunchAgents/com.claude.logs.daemon.plist
```