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
    full_project_dir=$(basename "$(dirname "$jsonl_path")")
    
    # Convert Claude's format back to actual directory path
    # The trick is that Claude replaces '/' with '-', so we need to be smart about it
    # Pattern: -Users-{username}-{location}-{project-name}
    # We reconstruct the path based on the pattern
    if [[ "$full_project_dir" =~ ^-Users-([^-]+)-dev-(.+)$ ]]; then
        username="${BASH_REMATCH[1]}"
        project_name="${BASH_REMATCH[2]}"
        actual_dir_path="/Users/$username/dev/$project_name"
    elif [[ "$full_project_dir" =~ ^-Users-([^-]+)-Documents-(.+)$ ]]; then
        username="${BASH_REMATCH[1]}"
        project_name="${BASH_REMATCH[2]}"
        actual_dir_path="/Users/$username/Documents/$project_name"
    elif [[ "$full_project_dir" =~ ^-Users-([^-]+)-dotfiles-(.+)$ ]]; then
        username="${BASH_REMATCH[1]}"
        project_name="${BASH_REMATCH[2]}"
        actual_dir_path="/Users/$username/dotfiles/$project_name"
    elif [[ "$full_project_dir" =~ ^-Users-([^-]+)-Desktop-(.+)$ ]]; then
        username="${BASH_REMATCH[1]}"
        project_name="${BASH_REMATCH[2]}"
        actual_dir_path="/Users/$username/Desktop/$project_name"
    elif [[ "$full_project_dir" =~ ^-Users-([^-]+)-(.+)$ ]]; then
        # Fallback for projects directly in home directory subdirs
        username="${BASH_REMATCH[1]}"
        project_name="${BASH_REMATCH[2]}"
        actual_dir_path="/Users/$username/$project_name"
    else
        # Last resort fallback
        actual_dir_path=$(echo "$full_project_dir" | sed 's/^-/\//' | tr '-' '/')
    fi
    
    # Extract the actual project name from Claude's path format
    # Pattern: -Users-{username}-{location}-{project-name}
    # We want just the project name part and the parent path
    if [[ "$full_project_dir" =~ -dev-(.+)$ ]]; then
        project_dir="${BASH_REMATCH[1]}"
        parent_path=$(echo "$full_project_dir" | sed 's/\(-dev-\).*/\1/' | sed 's/^-//' | sed 's/-$//')
    elif [[ "$full_project_dir" =~ -Documents-(.+)$ ]]; then
        project_dir="${BASH_REMATCH[1]}"
        parent_path=$(echo "$full_project_dir" | sed 's/\(-Documents-\).*/\1/' | sed 's/^-//' | sed 's/-$//')
    elif [[ "$full_project_dir" =~ -dotfiles-(.+)$ ]]; then
        project_dir="${BASH_REMATCH[1]}"
        parent_path=$(echo "$full_project_dir" | sed 's/\(-dotfiles-\).*/\1/' | sed 's/^-//' | sed 's/-$//')
    elif [[ "$full_project_dir" =~ -Desktop-(.+)$ ]]; then
        project_dir="${BASH_REMATCH[1]}"
        parent_path=$(echo "$full_project_dir" | sed 's/\(-Desktop-\).*/\1/' | sed 's/^-//' | sed 's/-$//')
    else
        # Fallback: take everything after the last occurrence of username
        project_dir=$(echo "$full_project_dir" | sed 's/.*-yuvalspiegel-//')
        parent_path=$(echo "$full_project_dir" | sed 's/-[^-]*$//' | sed 's/^-//')
    fi
    
    session_id=$(basename "$jsonl_path" .jsonl)
    
    # Create index filename with age prefix, num-msg, dir-name, and parent-dir-path labels
    index_filename="${age_prefix} num-msg:${num_messages} dir-name:${project_dir} parent-dir-path:${parent_path} ${session_id}"
    
    # Create index file with cd and claude resume command as content
    echo "cd $actual_dir_path ; claude -r $session_id" > "$LOGS_DIR/$index_filename"
    
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