#!/bin/bash

# Usage: sync-latest-jsonl.sh <source_path> <dest_path> [-r] [-d] [-n <count>]
# Paths can be local (e.g., /path/to/dir) or remote (e.g., host:/path/to/dir)
# Example (remote to remote): sync-latest-jsonl.sh jetson11.local:~/.claude_container/projects/-workspace yuval@treex-dev-tlv:~/treex-mono
# Example (local to remote): sync-latest-jsonl.sh /Users/me/workspace yuval@treex-dev-tlv:~/treex-mono
# Example (remote to local): sync-latest-jsonl.sh jetson11.local:~/workspace /tmp/backup
# Example with reverse: sync-latest-jsonl.sh jetson11.local:~/.claude_container/projects/-workspace yuval@treex-dev-tlv:~/treex-mono -r
# Example with directory sync: sync-latest-jsonl.sh jetson11.local:~/.claude_container/projects/-workspace yuval@treex-dev-tlv:~/treex-mono -d
# Example with N latest files: sync-latest-jsonl.sh jetson11.local:~/.claude_container/projects/-workspace yuval@treex-dev-tlv:~/treex-mono -n 5

if [ $# -lt 2 ] || [ $# -gt 6 ]; then
    echo "Usage: $0 <source_path> <dest_path> [-r] [-d] [-n <count>]"
    echo "  Paths can be local (/path/to/dir) or remote (host:/path/to/dir)"
    echo "  -r: reverse source and destination"
    echo "  -d: sync entire source directory to destination"
    echo "  -n <count>: number of most recent .jsonl files to sync (default: 1)"
    echo "Example (remote to remote): $0 jetson11.local:~/.claude_container/projects/-workspace yuval@treex-dev-tlv:~/treex-mono"
    echo "Example (local to remote): $0 /Users/me/workspace yuval@treex-dev-tlv:~/treex-mono"
    exit 1
fi

SOURCE="$1"
DEST="$2"
SYNC_DIR=false
NUM_FILES=1

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
        -n)
            shift
            NUM_FILES="$1"
            if ! [[ "$NUM_FILES" =~ ^[0-9]+$ ]] || [ "$NUM_FILES" -lt 1 ]; then
                echo "Error: -n requires a positive integer"
                exit 1
            fi
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# Helper function to check if path is remote (contains :) or local
is_remote() {
    [[ "$1" == *:* ]]
}

# Helper function to extract host from remote path
get_host() {
    echo "${1%%:*}"
}

# Helper function to extract path from remote or local
get_path() {
    if is_remote "$1"; then
        echo "${1#*:}"
    else
        echo "$1"
    fi
}

if [ "$SYNC_DIR" = true ]; then
    # Sync entire directory
    echo "Syncing entire directory from $SOURCE to $DEST..."

    # Create a temporary directory
    TEMP_DIR=$(mktemp -d)

    # Pull the entire source directory
    echo "Pulling directory from $SOURCE..."
    if is_remote "$SOURCE"; then
        rsync -avz "$(get_host "$SOURCE"):$(get_path "$SOURCE")/" "$TEMP_DIR/"
    else
        rsync -avz "$(get_path "$SOURCE")/" "$TEMP_DIR/"
    fi

    if [ $? -ne 0 ]; then
        echo "Error: Failed to pull directory from source"
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    # Push to destination
    echo "Pushing directory to $DEST..."
    if is_remote "$DEST"; then
        rsync -avz "$TEMP_DIR/" "$(get_host "$DEST"):$(get_path "$DEST")/"
    else
        rsync -avz "$TEMP_DIR/" "$(get_path "$DEST")/"
    fi

    if [ $? -ne 0 ]; then
        echo "Error: Failed to push directory to destination"
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    # Cleanup
    rm -rf "$TEMP_DIR"
    echo "Successfully synced directory from $SOURCE to $DEST"
else
    # Find the most recent .jsonl file(s) in the source directory
    echo "Finding $NUM_FILES most recent .jsonl file(s) in $SOURCE..."
    if is_remote "$SOURCE"; then
        LATEST_FILES=$(ssh "$(get_host "$SOURCE")" "ls -t $(get_path "$SOURCE")/*.jsonl 2>/dev/null | head -n$NUM_FILES")
    else
        LATEST_FILES=$(ls -t "$(get_path "$SOURCE")"/*.jsonl 2>/dev/null | head -n"$NUM_FILES")
    fi

    if [ -z "$LATEST_FILES" ]; then
        echo "Error: No .jsonl files found in $SOURCE"
        exit 1
    fi

    FILE_COUNT=$(echo "$LATEST_FILES" | wc -l | tr -d ' ')
    echo "Found $FILE_COUNT file(s)"

    while IFS= read -r LATEST_FILE; do
        FILENAME=$(basename "$LATEST_FILE")
        echo "Syncing: $FILENAME"

        # Pull the file locally
        if is_remote "$SOURCE"; then
            rsync -avz "$(get_host "$SOURCE"):$LATEST_FILE" "/tmp/$FILENAME"
        else
            rsync -avz "$LATEST_FILE" "/tmp/$FILENAME"
        fi

        if [ $? -ne 0 ]; then
            echo "Error: Failed to pull $FILENAME from source"
            exit 1
        fi

        # Push to destination
        if is_remote "$DEST"; then
            rsync -avz "/tmp/$FILENAME" "$(get_host "$DEST"):$(get_path "$DEST")/"
        else
            rsync -avz "/tmp/$FILENAME" "$(get_path "$DEST")/"
        fi

        if [ $? -ne 0 ]; then
            echo "Error: Failed to push $FILENAME to destination"
            rm -f "/tmp/$FILENAME"
            exit 1
        fi

        rm -f "/tmp/$FILENAME"
    done <<< "$LATEST_FILES"

    echo "Successfully synced $FILE_COUNT file(s) from $SOURCE to $DEST"
fi
