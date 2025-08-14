#!/bin/bash

# Calendar daemon - tags today with Red tag

CALENDAR_DIR="${CALENDAR_DIR:-$HOME/calendar}"
DAYS_DIR="$CALENDAR_DIR/days"
RED_TAG="Red"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

tag_today() {
    TODAY=$(date +%Y-%m-%d)
    TODAY_PATH="$DAYS_DIR/$TODAY"
    
    # Check if already tagged
    if [[ -d "$TODAY_PATH" ]] && tag -l "$TODAY_PATH" 2>/dev/null | grep -q "$RED_TAG"; then
        return 0  # Already correct
    fi
    
    # Remove Red tag from any other days (last 7 days)
    for i in {1..7}; do
        OLD_DATE=$(date -v-${i}d +%Y-%m-%d 2>/dev/null || date -d "-${i} days" +%Y-%m-%d)
        OLD_PATH="$DAYS_DIR/$OLD_DATE"
        if [[ -d "$OLD_PATH" ]]; then
            tag -r "$RED_TAG" "$OLD_PATH" 2>/dev/null
        fi
    done
    
    # Create today's directory if needed
    mkdir -p "$TODAY_PATH"
    
    # Tag today
    tag -a "$RED_TAG" "$TODAY_PATH"
    log "Tagged $TODAY with $RED_TAG"
}

# Main loop
log "Starting calendar daemon..."
tag_today

while true; do
    sleep 600  # 10 minutes
    tag_today
done