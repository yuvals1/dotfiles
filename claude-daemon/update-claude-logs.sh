#!/bin/bash

# Claude conversation logs indexer
# Creates empty index files in ~/personal/claude-logs/
# Format: {num-messages}-{project-dir}-{session-id}

set -euo pipefail

# Configuration
CLAUDE_PROJECTS_DIR="$HOME/.claude/projects"
LOGS_DIR="$HOME/personal/claude-logs"
LOCK_FILE="/tmp/claude-logs-updater.lock"

# Function to cleanup on exit
cleanup() {
    rm -f "$LOCK_FILE"
}
trap cleanup EXIT

# Check if already running
if [ -f "$LOCK_FILE" ]; then
    echo "Another instance is already running (lock file exists)"
    exit 1
fi
touch "$LOCK_FILE"

# Create logs directory if it doesn't exist
mkdir -p "$LOGS_DIR"

# Remove all existing index files
echo "Cleaning up old index files..."
rm -f "$LOGS_DIR"/*

# Counter for statistics
total_files=0
start_time=$(date +%s)

# Process each JSONL file
echo "Indexing Claude conversations..."
for jsonl_path in "$CLAUDE_PROJECTS_DIR"/*/*.jsonl; do
    # Skip if not a file
    [ -f "$jsonl_path" ] || continue
    
    # Count messages (lines in JSONL) - strip leading spaces
    num_messages=$(wc -l < "$jsonl_path" | tr -d ' ')
    
    # Get file modification time and calculate age in days and hours
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - get seconds since modification
        mod_seconds=$(stat -f "%m" "$jsonl_path")
    else
        # Linux
        mod_seconds=$(stat -c "%Y" "$jsonl_path")
    fi
    
    # Current time in seconds
    current_seconds=$(date +%s)
    
    # Calculate age in seconds
    age_seconds=$((current_seconds - mod_seconds))
    
    # Convert to days and hours
    days=$((age_seconds / 86400))
    remaining_seconds=$((age_seconds % 86400))
    hours=$((remaining_seconds / 3600))
    
    # Format as Xd-Yh
    age_prefix="${days}d-${hours}h"
    
    # Extract project directory name and session ID
    project_dir=$(basename "$(dirname "$jsonl_path")")
    session_id=$(basename "$jsonl_path" .jsonl)
    
    # Create index filename with age prefix and count label
    index_filename="${age_prefix}-count${num_messages}-${project_dir}-${session_id}"
    
    # Create empty index file
    touch "$LOGS_DIR/$index_filename"
    
    total_files=$((total_files + 1))
done

# Calculate execution time
end_time=$(date +%s)
duration=$((end_time - start_time))

# Report statistics
echo "Indexing complete!"
echo "  - Processed: $total_files conversations"
echo "  - Duration: ${duration} seconds"
echo "  - Index location: $LOGS_DIR"