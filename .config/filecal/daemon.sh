#!/bin/bash

# Enhanced calendar daemon
# - Tags today with Important
# - Creates 2 months of future folders
# - Tags days with events (Green or Red based on priority)

CALENDAR_DIR="${CALENDAR_DIR:-$HOME/personal/calendar}"
DAYS_DIR="$CALENDAR_DIR/days"
TAG_CMD="/usr/local/bin/tag"

# Tag names
IMPORTANT_TAG="Important"  # For today (shows ❗)
RED_TAG="Red"              # For days with important events
GREEN_TAG="Green"          # For days with regular events

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Remove all managed tags from a path
clear_tags() {
    local path="$1"
    $TAG_CMD -r "$IMPORTANT_TAG" "$path" 2>/dev/null
    $TAG_CMD -r "$RED_TAG" "$path" 2>/dev/null
    $TAG_CMD -r "$GREEN_TAG" "$path" 2>/dev/null
}

# Check if a day has events and what priority
check_day_content() {
    local day_path="$1"
    
    # Check if directory exists and has files
    if [[ ! -d "$day_path" ]]; then
        return 2  # Directory doesn't exist
    fi
    
    local file_count=$(find "$day_path" -maxdepth 1 -type f | wc -l | tr -d ' ')
    
    if [[ $file_count -eq 0 ]]; then
        return 1  # Empty directory
    fi
    
    # Check if any file contains Red category
    if grep -r "category:Red" "$day_path" >/dev/null 2>&1 || \
       grep -r "category:Important" "$day_path" >/dev/null 2>&1; then
        return 3  # Has important/red events
    fi
    
    return 0  # Has regular events
}

# Tag today with Important
tag_today() {
    local TODAY=$(date +%Y-%m-%d)
    local TODAY_PATH="$DAYS_DIR/$TODAY"
    
    # Create today's directory if needed
    mkdir -p "$TODAY_PATH"
    
    # Check if already correctly tagged
    if $TAG_CMD -l "$TODAY_PATH" 2>/dev/null | grep -q "$IMPORTANT_TAG"; then
        return 0  # Already tagged correctly
    fi
    
    # Remove Important tag from yesterday
    local YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "-1 day" +%Y-%m-%d)
    local YESTERDAY_PATH="$DAYS_DIR/$YESTERDAY"
    if [[ -d "$YESTERDAY_PATH" ]]; then
        $TAG_CMD -r "$IMPORTANT_TAG" "$YESTERDAY_PATH" 2>/dev/null
        log "Removed Important tag from $YESTERDAY"
    fi
    
    # Clear any other tags from today and add Important
    clear_tags "$TODAY_PATH"
    $TAG_CMD -a "$IMPORTANT_TAG" "$TODAY_PATH"
    log "Tagged $TODAY with Important"
}

# Create future date folders (2 months ahead)
create_future_folders() {
    local TODAY=$(date +%Y-%m-%d)
    
    # Create folders for next 60 days
    for i in {0..60}; do
        local FUTURE_DATE=$(date -v+${i}d +%Y-%m-%d 2>/dev/null || date -d "+${i} days" +%Y-%m-%d)
        local FUTURE_PATH="$DAYS_DIR/$FUTURE_DATE"
        
        if [[ ! -d "$FUTURE_PATH" ]]; then
            mkdir -p "$FUTURE_PATH"
            log "Created future folder: $FUTURE_DATE"
        fi
    done
}

# Tag all days based on their content
tag_all_days() {
    local TODAY=$(date +%Y-%m-%d)
    
    # Process all date folders
    for day_dir in "$DAYS_DIR"/????-??-??; do
        if [[ ! -d "$day_dir" ]]; then
            continue
        fi
        
        local day_name=$(basename "$day_dir")
        
        # Skip today (already has Important tag)
        if [[ "$day_name" == "$TODAY" ]]; then
            continue
        fi
        
        # Check day content and apply appropriate tag
        check_day_content "$day_dir"
        local status=$?
        
        # Get current tags
        local current_tags=$($TAG_CMD -l "$day_dir" 2>/dev/null)
        
        case $status in
            0)  # Has regular events - should be Green
                if ! echo "$current_tags" | grep -q "$GREEN_TAG"; then
                    clear_tags "$day_dir"
                    $TAG_CMD -a "$GREEN_TAG" "$day_dir"
                    log "Tagged $day_name with Green (has events)"
                fi
                ;;
            3)  # Has important/red events - should be Red
                if ! echo "$current_tags" | grep -q "$RED_TAG"; then
                    clear_tags "$day_dir"
                    $TAG_CMD -a "$RED_TAG" "$day_dir"
                    log "Tagged $day_name with Red (has important events)"
                fi
                ;;
            *)  # Empty or doesn't exist - should have no tags
                if echo "$current_tags" | grep -qE "$RED_TAG|$GREEN_TAG"; then
                    clear_tags "$day_dir"
                    log "Cleared tags from $day_name (now empty)"
                fi
                ;;
        esac
    done
}

# Main update function
update_calendar() {
    tag_today
    create_future_folders
    tag_all_days
}

# Main loop
log "Starting enhanced calendar daemon..."
update_calendar

while true; do
    sleep 600  # 10 minutes
    update_calendar
done