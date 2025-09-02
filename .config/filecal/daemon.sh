#!/bin/bash

# Enhanced calendar daemon
# - Tags today with Point
# - Creates 2 months of future folders

CALENDAR_DIR="${CALENDAR_DIR:-$HOME/personal/calendar}"
DAYS_DIR="$CALENDAR_DIR/days"
TAG_CMD="/usr/local/bin/tag"

# Todo directories
TODO_DIRS=(
    "overdue"
    "+general-tasks-red"
    "+scheduled-tasks-blue"
    "done"
    "backlog"
    "events"
)

# Tag names
IMPORTANT_TAG="Point"      # For today (shows 👉)

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Remove all managed tags from a path
clear_tags() {
    local path="$1"
    $TAG_CMD -r "$IMPORTANT_TAG" "$path" 2>/dev/null
}


# Tag today with Point
tag_today() {
    local TODAY=$(date +%Y-%m-%d)
    local TODAY_WEEKDAY=$(date +%w)  # 0=Sunday, 1=Monday, etc.
    
    # Format the day suffix
    if [[ "$TODAY_WEEKDAY" == "0" ]]; then
        local TODAY_SUFFIX="Sunday"
    else
        # Convert to 1=Sunday, 2=Monday format
        local DAY_NUM=$((TODAY_WEEKDAY + 1))
        local TODAY_SUFFIX="$DAY_NUM"
    fi
    
    local TODAY_PATH="$DAYS_DIR/${TODAY}  (${TODAY_SUFFIX})"
    
    # Create today's directory if needed
    mkdir -p "$TODAY_PATH"
    
    # Check if already correctly tagged
    if $TAG_CMD -l "$TODAY_PATH" 2>/dev/null | grep -q "$IMPORTANT_TAG"; then
        return 0  # Already tagged correctly
    fi
    
    # Remove Point tag from yesterday (check both with and without suffix)
    local YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "-1 day" +%Y-%m-%d)
    for yesterday_dir in "$DAYS_DIR"/${YESTERDAY}*; do
        if [[ -d "$yesterday_dir" ]]; then
            $TAG_CMD -r "$IMPORTANT_TAG" "$yesterday_dir" 2>/dev/null
            log "Removed Point tag from $(basename "$yesterday_dir")"
        fi
    done
    
    # Clear any other tags from today and add Point
    clear_tags "$TODAY_PATH"
    $TAG_CMD -a "$IMPORTANT_TAG" "$TODAY_PATH"
    log "Tagged $TODAY with Point"
}

# Create future date folders (2 months ahead)
create_future_folders() {
    local TODAY=$(date +%Y-%m-%d)
    
    # Create folders for next 60 days
    for i in {0..60}; do
        # Get date and weekday number
        local FUTURE_DATE=$(date -v+${i}d +%Y-%m-%d 2>/dev/null || date -d "+${i} days" +%Y-%m-%d)
        local WEEKDAY_NUM=$(date -v+${i}d +%w 2>/dev/null || date -d "+${i} days" +%w)  # 0=Sunday
        
        # Format the day suffix
        if [[ "$WEEKDAY_NUM" == "0" ]]; then
            local DAY_SUFFIX="Sunday"
        else
            # Convert to 1=Sunday, 2=Monday format
            local DAY_NUM=$((WEEKDAY_NUM + 1))
            local DAY_SUFFIX="$DAY_NUM"
        fi
        
        local FUTURE_PATH="$DAYS_DIR/${FUTURE_DATE}  (${DAY_SUFFIX})"
        
        if [[ ! -d "$FUTURE_PATH" ]]; then
            mkdir -p "$FUTURE_PATH"
            log "Created future folder: ${FUTURE_DATE}  (${DAY_SUFFIX})"
        fi
    done
}

# Create todo directories
create_todo_directories() {
    for dir in "${TODO_DIRS[@]}"; do
        local todo_dir="$CALENDAR_DIR/$dir"
        if [[ ! -d "$todo_dir" ]]; then
            mkdir -p "$todo_dir"
            log "Created todo directory: $dir"
        fi
    done
}

# Sync tagged files to todo directories
sync_todo_directories() {
    local TODAY=$(date +%Y-%m-%d)
    
    # Clear existing symlinks in all todo directories
    for dir in "${TODO_DIRS[@]}"; do
        local todo_dir="$CALENDAR_DIR/$dir"
        find "$todo_dir" -type l -delete 2>/dev/null
    done
    
    # First pass: Update overdue tags
    for day_dir in "$DAYS_DIR"/????-??-??*; do
        if [[ ! -d "$day_dir" ]]; then
            continue
        fi
        
        local day_name=$(basename "$day_dir")
        # Extract just the date part (first 10 characters: YYYY-MM-DD)
        local day_date="${day_name:0:10}"
        
        # Check if this date is in the past
        if [[ "$day_date" < "$TODAY" ]]; then
            # Process each file in the day directory
            for file_path in "$day_dir"/*; do
                if [[ ! -f "$file_path" ]]; then
                    continue
                fi
                
                local file_tags=$($TAG_CMD -l "$file_path" 2>/dev/null)
                
                # Update overdue tags
                if echo "$file_tags" | grep -qE "(Red|Blue|Purple|Waiting)"; then
                    # Remove old tags and add Overdue
                    $TAG_CMD -r "Red" "$file_path" 2>/dev/null
                    $TAG_CMD -r "Blue" "$file_path" 2>/dev/null
                    $TAG_CMD -r "Purple" "$file_path" 2>/dev/null
                    $TAG_CMD -r "Waiting" "$file_path" 2>/dev/null
                    $TAG_CMD -a "Overdue" "$file_path" 2>/dev/null
                fi
            done
        fi
    done
    
    # Second pass: Scan all files in days/ directories for symlink creation
    for day_dir in "$DAYS_DIR"/????-??-??*; do
        if [[ ! -d "$day_dir" ]]; then
            continue
        fi
        
        local day_name=$(basename "$day_dir")
        # Extract just the date part (first 10 characters: YYYY-MM-DD)
        local day_date="${day_name:0:10}"
        
        # Process each file in the day directory
        for file_path in "$day_dir"/*; do
            if [[ ! -f "$file_path" ]]; then
                continue
            fi
            
            local file_name=$(basename "$file_path")
            local file_tags=$($TAG_CMD -l "$file_path" 2>/dev/null)
            
            # Create symlinks based on tags
            if echo "$file_tags" | grep -q "Red"; then
                local symlink_path="$CALENDAR_DIR/+general-tasks-red/$file_name"
                ln -sf "../days/$day_name/$file_name" "$symlink_path"
            elif echo "$file_tags" | grep -q "Blue"; then
                local symlink_path="$CALENDAR_DIR/+scheduled-tasks-blue/$file_name"
                ln -sf "../days/$day_name/$file_name" "$symlink_path"
            elif echo "$file_tags" | grep -q "Done"; then
                local symlink_path="$CALENDAR_DIR/done/$file_name"
                ln -sf "../days/$day_name/$file_name" "$symlink_path"
            elif echo "$file_tags" | grep -q "Calendar-emoji"; then
                local symlink_name="${day_date}-${file_name}"
                local symlink_path="$CALENDAR_DIR/events/$symlink_name"
                ln -sf "../days/$day_name/$file_name" "$symlink_path"
            elif echo "$file_tags" | grep -q "Sleep"; then
                local symlink_path="$CALENDAR_DIR/backlog/$file_name"
                ln -sf "../days/$day_name/$file_name" "$symlink_path"
            elif echo "$file_tags" | grep -q "Overdue"; then
                local symlink_path="$CALENDAR_DIR/overdue/$file_name"
                ln -sf "../days/$day_name/$file_name" "$symlink_path"
            fi
        done
    done
    
    log "Synced todo directories"
}

# Sync Purple-tagged files from entire HOME directory
sync_purple_global() {
    local purple_dir="$CALENDAR_DIR/+current-project-tasks-purple"
    
    # Clear existing symlinks in purple directory
    find "$purple_dir" -type l -delete 2>/dev/null
    
    # Use mdfind to search entire HOME for Purple-tagged items
    mdfind -onlyin "$HOME" "kMDItemUserTags == 'Purple'" 2>/dev/null | while IFS= read -r item_path; do
        if [[ (-f "$item_path" || -d "$item_path") && ! "$item_path" =~ ^"$CALENDAR_DIR" ]]; then
            local file_name=$(basename "$item_path")
            local relative_path
            
            # Create relative path from calendar dir to the item
            if [[ "$item_path" == "$HOME"/* ]]; then
                # Item is under HOME - create relative path
                local rel_from_home="${item_path#$HOME/}"
                relative_path="../../../$rel_from_home"
            else
                # Item outside HOME - use absolute path
                relative_path="$item_path"
            fi
            
            local symlink_path="$purple_dir/$file_name"
            ln -sf "$relative_path" "$symlink_path"
        fi
    done
    
    log "Synced global Purple-tagged files"
}

# Sync Green-tagged files from entire HOME directory
sync_green_global() {
    local green_dir="$CALENDAR_DIR/+current-working-files-green"
    
    # Clear existing symlinks in green directory
    find "$green_dir" -type l -delete 2>/dev/null
    
    # Use mdfind to search entire HOME for Green-tagged items
    mdfind -onlyin "$HOME" "kMDItemUserTags == 'Green'" 2>/dev/null | while IFS= read -r item_path; do
        if [[ (-f "$item_path" || -d "$item_path") && ! "$item_path" =~ ^"$CALENDAR_DIR" ]]; then
            local file_name=$(basename "$item_path")
            local relative_path
            
            # Create relative path from calendar dir to the item
            if [[ "$item_path" == "$HOME"/* ]]; then
                # Item is under HOME - create relative path
                local rel_from_home="${item_path#$HOME/}"
                relative_path="../../../$rel_from_home"
            else
                # Item outside HOME - use absolute path
                relative_path="$item_path"
            fi
            
            local symlink_path="$green_dir/$file_name"
            ln -sf "$relative_path" "$symlink_path"
        fi
    done
    
    log "Synced global Green-tagged files"
}

# Main update function
update_calendar() {
    tag_today
    create_future_folders
    create_todo_directories
    sync_todo_directories
    sync_purple_global
    sync_green_global
}

# Check for command line argument
if [[ "$1" == "update" ]]; then
    # Run once and exit
    log "Running manual update..."
    update_calendar
    log "Manual update completed"
    exit 0
fi

# Main loop (daemon mode)
log "Starting enhanced calendar daemon..."
update_calendar

while true; do
    sleep 600  # 10 minutes
    update_calendar
done