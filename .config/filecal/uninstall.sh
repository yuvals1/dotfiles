#!/bin/bash

# Uninstall script for filecal daemon

PLIST_NAME="com.filecal.daemon"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_PATH="$LAUNCH_AGENTS_DIR/$PLIST_NAME.plist"

echo "🗑️  Uninstalling filecal daemon..."

# Stop and unload daemon if it's running
if launchctl list | grep -q "$PLIST_NAME"; then
    echo "Stopping daemon..."
    launchctl unload "$PLIST_PATH" 2>/dev/null || true
fi

# Remove plist file
if [[ -f "$PLIST_PATH" ]]; then
    echo "Removing launch agent..."
    rm "$PLIST_PATH"
fi

# Clean up logs
echo "Cleaning up logs..."
rm -f /tmp/filecal-daemon.log /tmp/filecal-daemon.err

echo "✅ Daemon uninstalled successfully!"