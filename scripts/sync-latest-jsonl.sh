#!/bin/bash

# Usage: sync-latest-jsonl.sh <source_remote:path> <dest_remote:path> [-r] [-d]
# Example: sync-latest-jsonl.sh jetson11.local:~/.claude_container/projects/-workspace yuval@treex-dev-tlv:~/treex-mono
# Example with reverse: sync-latest-jsonl.sh jetson11.local:~/.claude_container/projects/-workspace yuval@treex-dev-tlv:~/treex-mono -r
# Example with directory sync: sync-latest-jsonl.sh jetson11.local:~/.claude_container/projects/-workspace yuval@treex-dev-tlv:~/treex-mono -d

if [ $# -lt 2 ] || [ $# -gt 4 ]; then
    echo "Usage: $0 <source_remote:path> <dest_remote:path> [-r] [-d]"
    echo "  -r: reverse source and destination"
    echo "  -d: sync entire source directory to destination"
    echo "Example: $0 jetson11.local:~/.claude_container/projects/-workspace yuval@treex-dev-tlv:~/treex-mono"
    exit 1
fi

SOURCE="$1"
DEST="$2"
SYNC_DIR=false

# Parse flags
shift 2
while [ $# -gt 0 ]; do
    case "$1" in
        -r)
            echo "Reversing source and destination..."
            TEMP="$SOURCE"
            SOURCE="$DEST"
            DEST="$TEMP"
            ;;
        -d)
            SYNC_DIR=true
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

if [ "$SYNC_DIR" = true ]; then
    # Sync entire directory
    echo "Syncing entire directory from $SOURCE to $DEST..."

    # Create a temporary directory
    TEMP_DIR=$(mktemp -d)

    # Pull the entire source directory
    echo "Pulling directory from $SOURCE..."
    rsync -avz "${SOURCE%%:*}:${SOURCE#*:}/" "$TEMP_DIR/"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to pull directory from source"
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    # Push to destination
    echo "Pushing directory to $DEST..."
    rsync -avz "$TEMP_DIR/" "$DEST/"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to push directory to destination"
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    # Cleanup
    rm -rf "$TEMP_DIR"
    echo "Successfully synced directory from $SOURCE to $DEST"
else
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
fi
