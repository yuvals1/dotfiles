#!/bin/bash

# Usage: sync-latest-jsonl.sh <source_remote:path> <dest_remote:path>
# Example: sync-latest-jsonl.sh jetson11.local:~/.claude_container/projects/-workspace yuval@treex-dev-tlv:~/treex-mono

if [ $# -ne 2 ]; then
    echo "Usage: $0 <source_remote:path> <dest_remote:path>"
    echo "Example: $0 jetson11.local:~/.claude_container/projects/-workspace yuval@treex-dev-tlv:~/treex-mono"
    exit 1
fi

SOURCE="$1"
DEST="$2"

# Find the most recent .jsonl file in the source directory
echo "Finding most recent .jsonl file in $SOURCE..."
LATEST_FILE=$(ssh "${SOURCE%%:*}" "ls -t ${SOURCE#*:}/*.jsonl 2>/dev/null | head -n1")

if [ -z "$LATEST_FILE" ]; then
    echo "Error: No .jsonl files found in $SOURCE"
    exit 1
fi

FILENAME=$(basename "$LATEST_FILE")
echo "Found: $FILENAME"

# Pull the file locally
echo "Pulling $FILENAME from $SOURCE..."
rsync -avz "${SOURCE%%:*}:$LATEST_FILE" "/tmp/$FILENAME"

if [ $? -ne 0 ]; then
    echo "Error: Failed to pull file from source"
    exit 1
fi

# Push to destination
echo "Pushing $FILENAME to $DEST..."
rsync -avz "/tmp/$FILENAME" "$DEST/"

if [ $? -ne 0 ]; then
    echo "Error: Failed to push file to destination"
    rm "/tmp/$FILENAME"
    exit 1
fi

# Cleanup
rm "/tmp/$FILENAME"
echo "Successfully synced $FILENAME from $SOURCE to $DEST"
