#!/bin/bash

# Claude conversation logs indexer
# Creates empty index files in ~/personal/claude-logs/
# Format: {num-messages}-{project-dir}-{session-id}

set -euo pipefail

# Configuration
CLAUDE_PROJECTS_DIR="$HOME/.claude/projects"
LOGS_DIR="$HOME/personal/claude-logs/session-index"
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
    
    # Derive the original directory from the Claude project path
    # Claude stores projects based on where 'claude' was originally run
    project_name=$(basename "$(dirname "$jsonl_path")")
    
    # Remove leading dash and split by dashes
    path_without_dash="${project_name#-}"
    
    # Split the path into segments
    IFS='-' read -ra segments <<< "$path_without_dash"
    
    # Iteratively build the path by testing directory existence
    reconstructed_path=""
    current_segment=""
    
    for i in "${!segments[@]}"; do
        if [ -z "$current_segment" ]; then
            current_segment="${segments[$i]}"
        else
            current_segment="$current_segment-${segments[$i]}"
        fi
        
        # Test if this should be a directory boundary
        test_path="$reconstructed_path/$current_segment"
        
        if [ -d "$test_path" ]; then
            # This segment is a complete directory, add it to path
            reconstructed_path="$test_path"
            current_segment=""
        elif [ "$i" -eq "$((${#segments[@]} - 1))" ]; then
            # Last segment, must be part of the final directory
            reconstructed_path="$reconstructed_path/$current_segment"
        fi
    done
    
    # Always use the reconstructed path from the project name
    # This is where claude was originally started from
    original_dir_path="$reconstructed_path"
    
    # Extract project name and parent path from the reconstructed path for display
    # Replace dots with underscores in project directory name for filename safety
    project_dir=$(basename "$reconstructed_path" | tr '.' '_')
    # Replace slashes with dashes and dots with underscores in parent path for filename safety
    parent_path=$(dirname "$reconstructed_path" | sed 's/^\///' | tr '/' '-' | tr '.' '_')
    
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
    
    # Convert to days, hours, and minutes
    days=$((age_seconds / 86400))
    remaining_seconds=$((age_seconds % 86400))
    hours=$((remaining_seconds / 3600))
    remaining_seconds=$((remaining_seconds % 3600))
    minutes=$((remaining_seconds / 60))
    
    # Skip files older than 99 days
    if [ $days -gt 99 ]; then
        continue
    fi
    
    # Format as XXd-YYh-ZZm with zero padding
    age_prefix=$(printf "%02dd-%02dh-%02dm" "$days" "$hours" "$minutes")
    
    session_id=$(basename "$jsonl_path" .jsonl)
    
    # Create index filename with age prefix, msg, dir, and parent-dir-path labels
    index_filename="${age_prefix} msg:${num_messages} dir:---${project_dir}--- parent-dir-path:${parent_path} ${session_id}"
    
    # Create index file with cd and claude resume command as content
    echo "cd $original_dir_path ; claude -r $session_id" > "$LOGS_DIR/$index_filename"
    
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