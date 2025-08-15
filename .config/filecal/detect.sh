#!/bin/bash

# Calendar tag detection script
# Outputs JSON of required tag changes without making them

CALENDAR_DIR="${CALENDAR_DIR:-$HOME/personal/calendar}"
DAYS_DIR="$CALENDAR_DIR/days"
TAG_CMD="/usr/local/bin/tag"

# Tag names
POINT_TAG="Point"
RED_TAG="Red"
GREEN_TAG="Green"

# Output format: JSON array of objects with path and desired tag
echo "["

first=true
TODAY=$(date +%Y-%m-%d)

# Check each day directory (with or without day suffix)
for day_dir in "$DAYS_DIR"/????-??-??*; do
    if [[ ! -d "$day_dir" ]]; then
        continue
    fi
    
    day_name=$(basename "$day_dir")
    # Extract just the date part (first 10 characters: YYYY-MM-DD)
    day_date="${day_name:0:10}"
    
    # Determine what tag this day should have
    desired_tag=""
    
    if [[ "$day_date" == "$TODAY" ]]; then
        # Today should have Point tag
        desired_tag="$POINT_TAG"
    else
        # Check if directory has files
        file_count=$(find "$day_dir" -maxdepth 1 -type f | wc -l | tr -d ' ')
        
        if [[ $file_count -gt 0 ]]; then
            # Has files - check if any files have Red or Important tags
            has_red_file=false
            for file in "$day_dir"/*; do
                if [[ -f "$file" ]]; then
                    file_tags=$($TAG_CMD -l "$file" 2>/dev/null)
                    if echo "$file_tags" | grep -qE "Red|Important"; then
                        has_red_file=true
                        break
                    fi
                fi
            done
            
            if [[ "$has_red_file" == "true" ]]; then
                desired_tag="$RED_TAG"
            else
                desired_tag="$GREEN_TAG"
            fi
        else
            # Empty directory - should have no tag
            desired_tag=""
        fi
    fi
    
    # Get current tags
    current_tags=$($TAG_CMD -l "$day_dir" 2>/dev/null)
    
    # Check if change is needed
    needs_change=false
    
    if [[ -n "$desired_tag" ]]; then
        # Should have a tag - check if it has the right one
        if ! echo "$current_tags" | grep -q "$desired_tag"; then
            needs_change=true
        fi
    else
        # Should have no tag - check if it has any managed tags
        if echo "$current_tags" | grep -qE "$POINT_TAG|$RED_TAG|$GREEN_TAG"; then
            needs_change=true
        fi
    fi
    
    # Output change if needed
    if [[ "$needs_change" == "true" ]]; then
        if [[ "$first" != "true" ]]; then
            echo ","
        fi
        echo -n "  {\"path\": \"$day_dir\", \"tag\": \"$desired_tag\"}"
        first=false
    fi
done

echo ""
echo "]"
