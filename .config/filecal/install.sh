#!/bin/bash

# Install script for filecal daemon

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLIST_NAME="com.filecal.daemon"
PLIST_FILE="$SCRIPT_DIR/$PLIST_NAME.plist"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"

echo "📅 Installing filecal daemon..."

# Create LaunchAgents directory if it doesn't exist
mkdir -p "$LAUNCH_AGENTS_DIR"

# Stop and unload existing daemon if it's running
if launchctl list | grep -q "$PLIST_NAME"; then
    echo "Stopping existing daemon..."
    launchctl unload "$LAUNCH_AGENTS_DIR/$PLIST_NAME.plist" 2>/dev/null || true
fi

# Copy plist file
echo "Installing launch agent..."
cp "$PLIST_FILE" "$LAUNCH_AGENTS_DIR/"

# Load the daemon
echo "Starting daemon..."
launchctl load "$LAUNCH_AGENTS_DIR/$PLIST_NAME.plist"

# Verify it's running
if launchctl list | grep -q "$PLIST_NAME"; then
    echo "✅ Daemon installed and running successfully!"
    echo ""
    echo "The daemon will:"
    echo "  • Start automatically at login"
    echo "  • Tag today's calendar folder with Red"
    echo "  • Update the tag at midnight or after sleep"
    echo ""
    echo "Logs available at:"
    echo "  • /tmp/filecal-daemon.log"
    echo "  • /tmp/filecal-daemon.err"
else
    echo "❌ Failed to start daemon"
    exit 1
fi