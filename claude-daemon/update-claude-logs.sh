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
    
    # Skip conversations with less than 10 messages
    if [ $num_messages -lt 10 ]; then
        continue
    fi
    
    # Extract the actual directory path from the cwd field in the JSONL file
    # Read line by line and stop as soon as we find a cwd field
    actual_dir_path=""
    while IFS= read -r line; do
        if [[ "$line" == *'"cwd":"'* ]]; then
            actual_dir_path=$(echo "$line" | sed 's/.*"cwd":"\([^"]*\)".*/\1/')
            break
        fi
    done < "$jsonl_path"
    
    # Skip files without cwd (likely summary-only files or incomplete sessions)
    if [ -z "$actual_dir_path" ]; then
        continue
    fi
    
    # Extract project name and parent path from the actual directory
    project_dir=$(basename "$actual_dir_path")
    # Replace slashes with dashes and dots with underscores in parent path for filename safety
    parent_path=$(dirname "$actual_dir_path" | sed 's/^\///' | tr '/' '-' | tr '.' '_')
    
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
    
    # Skip files older than 99 days
    if [ $days -gt 99 ]; then
        continue
    fi
    
    # Format as XXd-YYh with zero padding
    age_prefix=$(printf "%02dd-%02dh" "$days" "$hours")
    
    session_id=$(basename "$jsonl_path" .jsonl)
    
    # Create index filename with age prefix, msg, dir, and parent-dir-path labels
    index_filename="${age_prefix} msg:${num_messages} dir:---${project_dir}--- parent-dir-path:${parent_path} ${session_id}"
    
    # Create index file with cd and claude resume command as content
    echo "cd $actual_dir_path ; claude -r $session_id" > "$LOGS_DIR/$index_filename"
    
    total_files=$((total_files + 1))
    
    # Debug: show progress every 10 files
    if [ $((total_files % 10)) -eq 0 ]; then
        echo "  Processed $total_files files so far..."
    fi
done

# Calculate execution time
end_time=$(date +%s)
duration=$((end_time - start_time))

# Report statistics
echo "Indexing complete!"
echo "  - Processed: $total_files conversations"
echo "  - Duration: ${duration} seconds"
echo "  - Index location: $LOGS_DIR"