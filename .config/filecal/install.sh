#!/bin/bash

# Install script for filecal daemon LaunchAgent

PLIST_NAME="com.filecal.daemon.plist"
SOURCE_PLIST="$(dirname "$0")/$PLIST_NAME"
DEST_PLIST="$HOME/Library/LaunchAgents/$PLIST_NAME"

echo "Installing filecal daemon LaunchAgent..."

# Create LaunchAgents directory if it doesn't exist
mkdir -p "$HOME/Library/LaunchAgents"

# Copy plist file to LaunchAgents
cp "$SOURCE_PLIST" "$DEST_PLIST"

# Unload if already loaded (ignore errors)
launchctl unload "$DEST_PLIST" 2>/dev/null

# Load the new agent
launchctl load "$DEST_PLIST"

echo "LaunchAgent installed and loaded successfully!"
echo "The daemon will run every 10 minutes."
echo ""
echo "To check status: launchctl list | grep filecal"
echo "To unload: launchctl unload ~/Library/LaunchAgents/$PLIST_NAME"
echo "To reload: launchctl unload ~/Library/LaunchAgents/$PLIST_NAME && launchctl load ~/Library/LaunchAgents/$PLIST_NAME"
echo ""
echo "Logs are at:"
echo "  - /tmp/filecal-daemon.log"
echo "  - /tmp/filecal-daemon.error.log"