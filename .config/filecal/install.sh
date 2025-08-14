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

# If daemon is already running, uninstall it first for clean restart
if launchctl list | grep -q "$PLIST_NAME"; then
    echo "Found existing daemon, restarting..."
    "$SCRIPT_DIR/uninstall.sh"
    echo ""
    echo "📅 Installing filecal daemon..."
fi

# Clean up all old tags from calendar directories
echo "Cleaning up existing tags..."
CALENDAR_DIR="${CALENDAR_DIR:-$HOME/personal/calendar}"
DAYS_DIR="$CALENDAR_DIR/days"
TAG_CMD="/usr/local/bin/tag"

# Remove all managed tags from all day directories
for day_dir in "$DAYS_DIR"/????-??-??; do
    if [[ -d "$day_dir" ]]; then
        # Remove all possible tags that the daemon manages
        $TAG_CMD -r "Important" "$day_dir" 2>/dev/null
        $TAG_CMD -r "Point" "$day_dir" 2>/dev/null
        $TAG_CMD -r "Red" "$day_dir" 2>/dev/null
        $TAG_CMD -r "Green" "$day_dir" 2>/dev/null
    fi
done
echo "Tags cleaned"

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