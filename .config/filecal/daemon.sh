#!/bin/bash

# Calendar daemon
# - Tags today with Point
# - Creates 2 months of future folders

CALENDAR_DIR="${CALENDAR_DIR:-$HOME/personal/calendar}"
DAYS_DIR="$CALENDAR_DIR/days"
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





# Main update function
update_calendar() {
    tag_today
    create_future_folders
}

# Run update
log "Running calendar update..."
update_calendar
log "Update completed"
