#!/bin/bash

# Calculate and display time spent in each mode with colored backgrounds for a specific date

TRACKING_DIR="$HOME/personal/tracking/logs"
HISTORY_DATE_FILE="/tmp/sketchybar_history_date"
CONFIG_FILE="$HOME/personal/tracking/stopwatch_modes.conf"
CONFIG_DIR="$HOME/.config/sketchybar"

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

# Function to create a history mode item
create_history_item() {
    local index=$1
    local icon="$2"
    local label="$3"
    local hours=$4
    local bg_color=$5
    local text_color=$6
    
    sketchybar --add item history_mode_$index center \
               --set history_mode_$index \
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
}

# Remove old history items (increased range for orphaned modes)
for i in {0..19}; do
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
    while IFS='|' read -r start_time end_time mode; do
        # Trim whitespace
        mode=$(echo "$mode" | xargs)
        start_time=$(echo "$start_time" | xargs)
        end_time=$(echo "$end_time" | xargs)
        
        # Calculate duration from start and end times
        # Convert times to seconds since midnight
        if [[ "$start_time" =~ ([0-9]+):([0-9]+):([0-9]+) ]]; then
            start_seconds=$(( 10#${BASH_REMATCH[1]} * 3600 + 10#${BASH_REMATCH[2]} * 60 + 10#${BASH_REMATCH[3]} ))
        else
            continue
        fi
        
        if [[ "$end_time" =~ ([0-9]+):([0-9]+):([0-9]+) ]]; then
            end_seconds=$(( 10#${BASH_REMATCH[1]} * 3600 + 10#${BASH_REMATCH[2]} * 60 + 10#${BASH_REMATCH[3]} ))
        else
            continue
        fi
        
        # Calculate duration (handle day wrap if needed)
        if [ $end_seconds -lt $start_seconds ]; then
            # Wrapped past midnight
            total_seconds=$(( (86400 - start_seconds) + end_seconds ))
        else
            total_seconds=$(( end_seconds - start_seconds ))
        fi
        
        if [ $total_seconds -gt 0 ]; then
            
            # Add to mode's total - more efficient temp file update
            if grep -q "^$mode|" "$TEMP_FILE"; then
                # Mode exists, update it
                awk -F'|' -v mode="$mode" -v add="$total_seconds" '
                    $1 == mode { print $1 "|" ($2 + add); next }
                    { print }
                ' "$TEMP_FILE" > "$TEMP_FILE.tmp" && mv "$TEMP_FILE.tmp" "$TEMP_FILE"
            else
                echo "$mode|$total_seconds" >> "$TEMP_FILE"
            fi
        fi
    done < "$LOG_FILE"
fi

# Create items for each mode with time - in config file order
item_index=0
has_data=false
DISPLAYED_MODES=""

# Single pass through config file
while IFS='|' read -r config_mode config_icon config_color; do
    # Skip comments and empty lines
    [[ "$config_mode" =~ ^#.*$ ]] && continue
    [[ -z "$config_mode" ]] && continue
    
    # Track this mode as displayed
    DISPLAYED_MODES="$DISPLAYED_MODES|$config_mode|"
    
    # Check if this mode has any time tracked
    mode_line=$(grep "^$config_mode|" "$TEMP_FILE" 2>/dev/null)
    if [ -n "$mode_line" ]; then
        seconds=$(echo "$mode_line" | cut -d'|' -f2)
        
        if [ $seconds -gt 0 ]; then
            has_data=true
            hours=$(seconds_to_hours $seconds)
            
            # Use config values directly (we already have them)
            icon="$config_icon"
            label="$config_mode"  # Mode is now the label
            color_name="$config_color"
            
            # Get actual color value
            bg_color=$(get_color_from_name "$color_name")
            
            # Determine text color (black for yellow, white for others)
            if [ "$color_name" = "yellow" ]; then
                text_color="$BLACK"
            else
                text_color="$WHITE"
            fi
            
            # Create item with colored background
            create_history_item $item_index "$icon" "$label" "$hours" "$bg_color" "$text_color"
            
            item_index=$((item_index + 1))
        fi
    fi
done < "$CONFIG_FILE"

# Find and display orphaned modes
while IFS='|' read -r mode seconds; do
    # Check if this mode was already displayed
    if [[ "$DISPLAYED_MODES" != *"|$mode|"* ]]; then
        if [ $seconds -gt 0 ]; then
            has_data=true
            hours=$(seconds_to_hours $seconds)
            
            # Display with no icon, default background, mode name as label
            create_history_item $item_index "" "$mode" "$hours" "$ITEM_BG_COLOR" "$WHITE"
            
            item_index=$((item_index + 1))
        fi
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