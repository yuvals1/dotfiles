#!/bin/bash

# Calculate and display time spent in each mode with colored backgrounds for a specific date

TRACKING_DIR="$HOME/tracking"
HISTORY_DATE_FILE="/tmp/sketchybar_history_date"
CONFIG_DIR="$HOME/.config/sketchybar"
CONFIG_FILE="$CONFIG_DIR/stopwatch_modes.conf"

# Get the date to display (default to today)
if [ -f "$HISTORY_DATE_FILE" ]; then
    DISPLAY_DATE=$(cat "$HISTORY_DATE_FILE")
else
    DISPLAY_DATE=$(date '+%Y-%m-%d')
    echo "$DISPLAY_DATE" > "$HISTORY_DATE_FILE"
fi

LOG_FILE="$TRACKING_DIR/${DISPLAY_DATE}.log"

# Source colors
source "$CONFIG_DIR/colors.sh"

# Function to convert seconds to hours with 1 decimal
seconds_to_hours() {
    local seconds=$1
    printf "%.1f" $(echo "scale=2; $seconds / 3600" | bc)
}

# Function to get color from name
get_color_from_name() {
    local color_name="$1"
    case "$color_name" in
        "blue") echo "0xff4a90e2" ;;
        "red") echo "0xffff6b6b" ;;
        "yellow") echo "0xffffeb3b" ;;
        "green") echo "$GREEN" ;;
        "purple") echo "0xff9370db" ;;
        "teal") echo "$ACCENT_COLOR" ;;
        "orange") echo "$ORANGE" ;;
        *) echo "$ITEM_BG_COLOR" ;;
    esac
}

# Remove old history items
for i in {0..9}; do
    sketchybar --remove history_mode_$i 2>/dev/null
done
sketchybar --remove history_date 2>/dev/null

# Format date for display
DISPLAY_DATE_FORMATTED=$(date -j -f "%Y-%m-%d" "$DISPLAY_DATE" "+%a %b %d, %Y" 2>/dev/null || date -d "$DISPLAY_DATE" "+%a %b %d, %Y")

# Check if this is today
TODAY=$(date '+%Y-%m-%d')
if [ "$DISPLAY_DATE" = "$TODAY" ]; then
    DATE_LABEL="Today - $DISPLAY_DATE_FORMATTED"
else
    DATE_LABEL="$DISPLAY_DATE_FORMATTED"
fi

# Create date display item
sketchybar --add item history_date center \
           --set history_date \
                 label="$DATE_LABEL" \
                 label.color="$WHITE" \
                 icon="📅" \
                 icon.color="$WHITE" \
                 background.color="$ITEM_BG_COLOR" \
                 background.drawing=on \
                 background.corner_radius=5 \
                 padding_left=10 \
                 padding_right=10

# Temporary file to store mode totals
TEMP_FILE="/tmp/stopwatch_history_$$"
> "$TEMP_FILE"

# Process today's log file if it exists
if [ -f "$LOG_FILE" ]; then
    while IFS='|' read -r start_time end_time duration mode label; do
        # Trim whitespace
        mode=$(echo "$mode" | xargs)
        
        # Parse duration (HH:MM:SS to seconds)
        if [[ "$duration" =~ ([0-9]+):([0-9]+):([0-9]+) ]]; then
            hours="${BASH_REMATCH[1]}"
            minutes="${BASH_REMATCH[2]}"  
            seconds="${BASH_REMATCH[3]}"
            
            total_seconds=$((hours * 3600 + minutes * 60 + seconds))
            
            # Add to mode's total in temp file
            existing=$(grep "^$mode|" "$TEMP_FILE" | cut -d'|' -f2)
            if [ -n "$existing" ]; then
                new_total=$((existing + total_seconds))
                # Update the line
                grep -v "^$mode|" "$TEMP_FILE" > "$TEMP_FILE.tmp"
                echo "$mode|$new_total" >> "$TEMP_FILE.tmp"
                mv "$TEMP_FILE.tmp" "$TEMP_FILE"
            else
                echo "$mode|$total_seconds" >> "$TEMP_FILE"
            fi
        fi
    done < "$LOG_FILE"
fi

# Create items for each mode with time
item_index=0
has_data=false

while IFS='|' read -r mode seconds; do
    if [ $seconds -gt 0 ]; then
        has_data=true
        hours=$(seconds_to_hours $seconds)
        
        # Get icon, label and color for this mode from config
        icon=""
        label=""
        color_name=""
        while IFS='|' read -r config_mode config_icon config_label config_color; do
            [[ "$config_mode" =~ ^#.*$ ]] && continue
            [[ -z "$config_mode" ]] && continue
            
            if [ "$config_mode" = "$mode" ]; then
                icon="$config_icon"
                label="$config_label"
                color_name="$config_color"
                break
            fi
        done < "$CONFIG_FILE"
        
        # Use mode name as fallback if label not found
        if [ -z "$label" ]; then
            label="$mode"
        fi
        
        # Get actual color value
        bg_color=$(get_color_from_name "$color_name")
        
        # Determine text color (black for yellow, white for others)
        if [ "$color_name" = "yellow" ]; then
            text_color="$BLACK"
        else
            text_color="$WHITE"
        fi
        
        # Create item with colored background
        sketchybar --add item history_mode_$item_index center \
                   --set history_mode_$item_index \
                         icon="$icon" \
                         icon.color="$text_color" \
                         label="${label}: ${hours}h" \
                         label.color="$text_color" \
                         background.color="$bg_color" \
                         background.drawing=on \
                         background.corner_radius=5 \
                         background.height=24 \
                         padding_left=5 \
                         padding_right=5
        
        item_index=$((item_index + 1))
    fi
done < "$TEMP_FILE"

# If no data, show a message
if [ "$has_data" = false ]; then
    sketchybar --add item history_mode_0 center \
               --set history_mode_0 \
                     label="No time tracked" \
                     label.color="$WHITE" \
                     icon="📊" \
                     icon.color="$WHITE" \
                     background.color="$ITEM_BG_COLOR" \
                     background.drawing=on
fi

# Clean up
rm -f "$TEMP_FILE"