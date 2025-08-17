#!/bin/bash

# Source task folder environment variables
source "$HOME/.zsh/task-folders.zsh"

PROGRESS_DIR="$TASK_PROGRESS_PATH"
WAITING_DIR="$TASK_WAITING_PATH"
BACKLOG_DIR="$TASK_BACKLOG_PATH"
OVERDUE_TAG="Overdue"

# Ensure progress directory exists
mkdir -p "$PROGRESS_DIR"

# Function to check if a file is overdue
is_overdue() {
    local file="$1"
    local due_line=$(grep -E "^due: " "$file" 2>/dev/null | head -1)
    
    if [ -n "$due_line" ]; then
        # Extract the date/time
        local due_datetime=$(echo "$due_line" | sed 's/^due: //')
        
        # Convert to timestamp for comparison
        # Handle both date-only and date-time formats
        local due_timestamp
        if [[ "$due_datetime" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
            # Date only - assume end of day
            due_timestamp=$(date -j -f "%Y-%m-%d" "$due_datetime" "+%s" 2>/dev/null)
            due_timestamp=$((due_timestamp + 86399)) # Add 23:59:59
        else
            # Date and time
            due_timestamp=$(date -j -f "%Y-%m-%d %H:%M" "$due_datetime" "+%s" 2>/dev/null)
        fi
        
        # Get current timestamp
        local current_timestamp=$(date "+%s")
        
        # Check if overdue
        if [ -n "$due_timestamp" ] && [ "$current_timestamp" -gt "$due_timestamp" ]; then
            return 0 # true - is overdue
        fi
    fi
    return 1 # false - not overdue
}

# Function to check if file has overdue tag
has_overdue_tag() {
    local file="$1"
    tag -l "$file" 2>/dev/null | grep -q "$OVERDUE_TAG"
    return $?
}

# Function to add overdue tag
add_overdue_tag() {
    local file="$1"
    if ! has_overdue_tag "$file"; then
        tag -a "$OVERDUE_TAG" "$file"
    fi
}

# Function to remove overdue tag
remove_overdue_tag() {
    local file="$1"
    if has_overdue_tag "$file"; then
        tag -r "$OVERDUE_TAG" "$file"
    fi
}

# Function to move overdue tasks from a folder to in-progress
move_overdue_to_progress() {
    local source_dir="$1"
    
    find "$source_dir" -type f | while read -r file; do
        if is_overdue "$file"; then
            # Add overdue tag
            add_overdue_tag "$file"
            # Move to in-progress folder
            mv "$file" "$PROGRESS_DIR/"
        fi
    done
}

# Check waiting and backlog folders - move overdue tasks to in-progress
move_overdue_to_progress "$WAITING_DIR"
move_overdue_to_progress "$BACKLOG_DIR"

# Process in-progress folder - add/remove overdue tag as needed
find "$PROGRESS_DIR" -type f | while read -r file; do
    if is_overdue "$file"; then
        # Should have overdue tag
        add_overdue_tag "$file"
    else
        # Should not have overdue tag
        remove_overdue_tag "$file"
    fi
done

# Update sketchybar - show count of overdue tasks
# Use command substitution to avoid subshell issue with while loop
overdue_count=$(find "$PROGRESS_DIR" -type f -exec sh -c 'tag -l "$1" 2>/dev/null | grep -q "Overdue" && echo 1' _ {} \; | wc -l | tr -d ' ')

if [ "$overdue_count" -gt 0 ]; then
    sketchybar --set $NAME label="$overdue_count" drawing=on
else
    sketchybar --set $NAME drawing=off
fi