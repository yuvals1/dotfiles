#!/bin/bash

# Calendar daemon
# - Tags today with Point
# - Creates 2 weeks of future folders
# - Updates overdue tags for past-dated tasks
# - Archives past-dated directories to past-days
# - Tracks overdue count in days/overdue-count file

CALENDAR_DIR="${CALENDAR_DIR:-$HOME/personal/calendar}"
DAYS_DIR="$CALENDAR_DIR/days"
PAST_DAYS_DIR="$DAYS_DIR/past-days"
TAG_CMD="/usr/local/bin/tag"


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

# Update overdue tags for past-dated tasks
update_overdue_tags() {
    local TODAY=$(date +%Y-%m-%d)
    
    # Check only past-days directory (archive_past_days runs first)
    if [[ -d "$PAST_DAYS_DIR" ]]; then
        for day_dir in "$PAST_DAYS_DIR"/????-??-??*; do
            if [[ ! -d "$day_dir" ]]; then
                continue
            fi
            
            local day_name=$(basename "$day_dir")
            # Extract just the date part (first 10 characters: YYYY-MM-DD)
            local day_date="${day_name:0:10}"
            
            # Check if this date is in the past (should always be true in past-days)
            if [[ "$day_date" < "$TODAY" ]]; then
                # Process all files recursively in the day directory
                find "$day_dir" -type f 2>/dev/null | while IFS= read -r file_path; do
                    local file_tags=$($TAG_CMD -l "$file_path" 2>/dev/null)
                    
                    # Update overdue tags
                    if echo "$file_tags" | grep -qE "(Yellow|Blue|Purple|Waiting)"; then
                        # Remove old tags and add Overdue
                        $TAG_CMD -r "Yellow" "$file_path" 2>/dev/null
                        $TAG_CMD -r "Blue" "$file_path" 2>/dev/null
                        $TAG_CMD -r "Purple" "$file_path" 2>/dev/null
                        $TAG_CMD -r "Waiting" "$file_path" 2>/dev/null
                        $TAG_CMD -a "Overdue" "$file_path" 2>/dev/null
                        log "Updated overdue tag for: $(basename "$file_path")"
                    fi
                done
            fi
        done
    fi
    
    log "Completed overdue tag updates"
}

# Update overdue count file
update_overdue_count() {
    local OVERDUE_COUNT_FILE="$CALENDAR_DIR/overdue-count"
    local overdue_count=0
    
    # Count files with Overdue tag in past-days only
    # (current/future days can't have overdue items)
    if [[ -d "$PAST_DAYS_DIR" ]]; then
        while IFS= read -r file_path; do
            if [[ -f "$file_path" ]]; then
                local file_tags=$($TAG_CMD -l "$file_path" 2>/dev/null)
                if echo "$file_tags" | grep -q "Overdue"; then
                    ((overdue_count++))
                fi
            fi
        done < <(find "$PAST_DAYS_DIR" -type f 2>/dev/null)
    fi
    
    # Update or remove the count file based on count
    if [[ $overdue_count -gt 0 ]]; then
        echo "$overdue_count" > "$OVERDUE_COUNT_FILE"
        log "Updated overdue count: $overdue_count"
    else
        if [[ -f "$OVERDUE_COUNT_FILE" ]]; then
            rm "$OVERDUE_COUNT_FILE"
            log "Removed overdue count file (no overdue items)"
        fi
    fi
}

# Archive past-dated directories to past-days
archive_past_days() {
    local TODAY=$(date +%Y-%m-%d)
    
    # Create past-days directory if it doesn't exist
    mkdir -p "$PAST_DAYS_DIR"
    
    # Move past-dated directories to past-days
    for day_dir in "$DAYS_DIR"/????-??-??*; do
        if [[ ! -d "$day_dir" ]] || [[ "$day_dir" == *"past-days"* ]]; then
            continue
        fi
        
        local day_name=$(basename "$day_dir")
        # Extract just the date part (first 10 characters: YYYY-MM-DD)
        local day_date="${day_name:0:10}"
        
        # Check if this date is in the past (excluding today)
        if [[ "$day_date" < "$TODAY" ]]; then
            # Move the directory to past-days
            mv "$day_dir" "$PAST_DAYS_DIR/"
            log "Archived past day: $day_name"
        fi
    done
    
    log "Completed archiving past days"
}

# Create future date folders (2 weeks ahead)
create_future_folders() {
    local TODAY=$(date +%Y-%m-%d)
    
    # Create folders for next 14 days
    for i in {0..14}; do
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





# Main update function
update_calendar() {
    tag_today
    archive_past_days
    update_overdue_tags
    update_overdue_count
    create_future_folders
}

# Run update
log "Running calendar update..."
update_calendar
log "Update completed"
