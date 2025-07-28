#!/bin/bash

# Source task folder environment variables
source "$HOME/.zsh/task-folders.zsh"

PROGRESS_DIR="$HOME/tasks/$TASK_PROGRESS"
WAITING_DIR="$HOME/tasks/$TASK_WAITING"
BACKLOG_DIR="$HOME/tasks/$TASK_BACKLOG"
OVERDUE_EMOJI="⏰"

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

# Function to move overdue tasks from a folder to in-progress
move_overdue_to_progress() {
    local source_dir="$1"
    
    find "$source_dir" -type f | while read -r file; do
        
        # Get the filename without path
        filename=$(basename "$file")
        
        if is_overdue "$file"; then
            # Add overdue emoji if not already present
            if [[ "$filename" != *"$OVERDUE_EMOJI"* ]]; then
                new_filename="${OVERDUE_EMOJI} ${filename}"
            else
                new_filename="$filename"
            fi
            # Move to in-progress folder
            mv "$file" "$PROGRESS_DIR/$new_filename"
        fi
    done
}

# Check waiting and backlog folders - move overdue tasks to in-progress
move_overdue_to_progress "$WAITING_DIR"
move_overdue_to_progress "$BACKLOG_DIR"

# Process in-progress folder - add/remove overdue emoji as needed
find "$PROGRESS_DIR" -type f | while read -r file; do
    
    # Get the filename without path
    filename=$(basename "$file")
    
    # Check if file has overdue emoji
    has_emoji=false
    [[ "$filename" == *"$OVERDUE_EMOJI"* ]] && has_emoji=true
    
    # Check if file is currently overdue
    if is_overdue "$file"; then
        # Should have emoji - add if missing
        if [ "$has_emoji" = false ]; then
            new_filename="${OVERDUE_EMOJI} ${filename}"
            mv "$file" "$PROGRESS_DIR/$new_filename"
        fi
    else
        # Should not have emoji - remove if present
        if [ "$has_emoji" = true ]; then
            new_filename=$(echo "$filename" | sed "s/$OVERDUE_EMOJI //g")
            mv "$file" "$PROGRESS_DIR/$new_filename"
        fi
    fi
done

# Update sketchybar - show count of overdue tasks
overdue_count=$(find "$PROGRESS_DIR" -name "*$OVERDUE_EMOJI*" -type f | wc -l | tr -d ' ')
if [ "$overdue_count" -gt 0 ]; then
    sketchybar --set $NAME label="$OVERDUE_EMOJI $overdue_count" drawing=on
else
    sketchybar --set $NAME drawing=off
fi