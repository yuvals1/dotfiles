#!/bin/bash

# Enhanced calendar daemon
# - Tags today with Point
# - Creates 2 months of future folders
# - Tags days with events (Green or Red based on priority)

CALENDAR_DIR="${CALENDAR_DIR:-$HOME/personal/calendar}"
DAYS_DIR="$CALENDAR_DIR/days"
TAG_CMD="/usr/local/bin/tag"

# Tag names
IMPORTANT_TAG="Point"      # For today (shows 👉)
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
    
    # Check if any file has Red macOS tags
    for file in "$day_path"/*; do
        if [[ -f "$file" ]]; then
            local file_tags=$($TAG_CMD -l "$file" 2>/dev/null)
            if echo "$file_tags" | grep -q "Red"; then
                return 3  # Has important/red events
            fi
        fi
    done
    
    return 0  # Has regular events
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

# Tag all days based on their content
tag_all_days() {
    local TODAY=$(date +%Y-%m-%d)
    
    # Process all date folders (with or without day suffix)
    for day_dir in "$DAYS_DIR"/????-??-??*; do
        if [[ ! -d "$day_dir" ]]; then
            continue
        fi
        
        local day_name=$(basename "$day_dir")
        # Extract just the date part (first 10 characters: YYYY-MM-DD)
        local day_date="${day_name:0:10}"
        
        # Skip today (already has Point tag)
        if [[ "$day_date" == "$TODAY" ]]; then
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