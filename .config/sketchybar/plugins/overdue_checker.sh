#!/bin/bash

# Source task folder environment variables
source "$HOME/.zsh/task-folders.zsh"

PROGRESS_DIR="$HOME/tasks/$TASK_PROGRESS"
WAITING_DIR="$HOME/tasks/$TASK_WAITING"
OVERDUE_EMOJI="⏰"

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

# Check waiting folder first - move overdue tasks to in-progress
for file in "$WAITING_DIR"/*; do
    # Skip if not a regular file
    [ -f "$file" ] || continue
    
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
        mkdir -p "$PROGRESS_DIR"
        mv "$file" "$PROGRESS_DIR/$new_filename"
    fi
done

# Check in-progress folder - add overdue emoji to filenames
for file in "$PROGRESS_DIR"/*; do
    # Skip if not a regular file
    [ -f "$file" ] || continue
    
    # Get the filename without path
    filename=$(basename "$file")
    
    # Skip if already has overdue emoji
    [[ "$filename" == *"$OVERDUE_EMOJI"* ]] && continue
    
    if is_overdue "$file"; then
        # Add overdue emoji to filename
        new_filename="${OVERDUE_EMOJI} ${filename}"
        mv "$file" "$PROGRESS_DIR/$new_filename"
    fi
done

# Remove overdue emoji from tasks that are no longer overdue
for file in "$PROGRESS_DIR"/*; do
    # Skip if not a regular file
    [ -f "$file" ] || continue
    
    # Get the filename without path
    filename=$(basename "$file")
    
    # Only process files with overdue emoji
    [[ "$filename" == *"$OVERDUE_EMOJI"* ]] || continue
    
    # Read the file content to check for due date
    due_line=$(grep -E "^due: " "$file" 2>/dev/null | head -1)
    
    if [ -n "$due_line" ]; then
        # Extract the date/time
        due_datetime=$(echo "$due_line" | sed 's/^due: //')
        
        # Convert to timestamp for comparison
        if [[ "$due_datetime" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
            due_timestamp=$(date -j -f "%Y-%m-%d" "$due_datetime" "+%s" 2>/dev/null)
            due_timestamp=$((due_timestamp + 86399))
        else
            due_timestamp=$(date -j -f "%Y-%m-%d %H:%M" "$due_datetime" "+%s" 2>/dev/null)
        fi
        
        # Get current timestamp
        current_timestamp=$(date "+%s")
        
        # Check if no longer overdue
        if [ -n "$due_timestamp" ] && [ "$current_timestamp" -le "$due_timestamp" ]; then
            # Remove overdue emoji from filename
            new_filename=$(echo "$filename" | sed "s/$OVERDUE_EMOJI //g")
            mv "$file" "$PROGRESS_DIR/$new_filename"
        fi
    else
        # No due date found, remove overdue emoji
        new_filename=$(echo "$filename" | sed "s/$OVERDUE_EMOJI //g")
        mv "$file" "$PROGRESS_DIR/$new_filename"
    fi
done

# Update sketchybar (optional - show count of overdue tasks)
overdue_count=$(find "$PROGRESS_DIR" -name "*$OVERDUE_EMOJI*" -type f | wc -l | tr -d ' ')
if [ "$overdue_count" -gt 0 ]; then
    sketchybar --set $NAME label="$OVERDUE_EMOJI $overdue_count" drawing=on
else
    sketchybar --set $NAME drawing=off
fi