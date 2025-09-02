#!/bin/bash

# Unified stopwatch plugin for sketchybar
# Uses sketchybar's update mechanism instead of background processes
# Actions: click (toggle), tick (update display), cycle_mode, render_modes

START_FILE="/tmp/sketchybar_stopwatch_start"
MODE_FILE="/tmp/sketchybar_stopwatch_mode"
CONFIG_FILE="$HOME/personal/tracking/stopwatch_modes.conf"
CONFIG_DIR="$HOME/.config/sketchybar"

# Source colors
source "$CONFIG_DIR/theme.sh"

# Handle different actions
ACTION="${1:-click}"

# Tracking directory
TRACKING_DIR="$HOME/personal/tracking/logs"

# Function to log session to daily file
log_session() {
    local start_epoch="$1"
    local end_epoch="$2"
    local duration="$3"
    
    # Create tracking directory if it doesn't exist
    mkdir -p "$TRACKING_DIR"
    
    # Get date for filename (based on start time)
    local date_str=$(date -r "$start_epoch" '+%Y-%m-%d')
    local log_file="$TRACKING_DIR/${date_str}.log"
    
    # Format timestamps
    local start_time=$(date -r "$start_epoch" '+%H:%M:%S')
    local end_time=$(date -r "$end_epoch" '+%H:%M:%S')
    
    # Format duration (seconds to HH:MM:SS)
    local hours=$((duration / 3600))
    local minutes=$(( (duration % 3600) / 60 ))
    local seconds=$((duration % 60))
    local duration_str=$(printf "%02d:%02d:%02d" $hours $minutes $seconds)
    
    # Get current mode
    local mode=$(cat "$MODE_FILE" 2>/dev/null || echo "unknown")
    
    # Log entry format: START_TIME | END_TIME | MODE
    echo "${start_time} | ${end_time} | ${mode}" >> "$log_file"
}

# Function to get default mode from config
get_default_mode() {
    while IFS='|' read -r mode rest; do
        [[ "$mode" =~ ^#.*$ ]] && continue
        [[ -z "$mode" ]] && continue
        echo "$mode"
        return
    done < "$CONFIG_FILE"
    echo "Work"  # Fallback if config is empty
}

# Function to get icon for current mode
get_mode_icon() {
    local mode=$(cat "$MODE_FILE" 2>/dev/null || get_default_mode)
    
    while IFS='|' read -r m icon color; do
        [[ "$m" =~ ^#.*$ ]] && continue
        [[ -z "$m" ]] && continue
        
        if [[ "$m" == "$mode" ]]; then
            echo "$icon"
            return
        fi
    done < "$CONFIG_FILE"
    
    # Default icon if not found
    echo "$STOPWATCH_ICON"
}

# Function to map color names to hex values
map_color_to_hex() {
    local color_name="$1"
    case "$color_name" in
        "blue") echo "0xff4a90e2" ;;  # Nice medium blue
        "red") echo "0xffff6b6b" ;;
        "yellow") echo "0xffffeb3b" ;;  # Bright yellow
        "green") echo "$GREEN" ;;
        "purple") echo "0xff9370db" ;;
        "pink") echo "0xffe91e63" ;;
        "teal") echo "$ACCENT_COLOR" ;;
        "orange") echo "$ORANGE" ;;
        *) echo "$ITEM_BG_COLOR" ;;
    esac
}

# Function to get appropriate text color for background
get_text_color_for_background() {
    local color_name="$1"
    # Light backgrounds that need black text
    case "$color_name" in
        "yellow"|"white"|"light-blue"|"light-green") 
            echo "$BLACK" ;;
        *)
            echo "$WHITE" ;;
    esac
}

# Function to get color for current mode
get_mode_color() {
    local mode=$(cat "$MODE_FILE" 2>/dev/null || get_default_mode)
    
    while IFS='|' read -r m icon color; do
        [[ "$m" =~ ^#.*$ ]] && continue
        [[ -z "$m" ]] && continue
        
        if [[ "$m" == "$mode" ]]; then
            map_color_to_hex "$color"
            return
        fi
    done < "$CONFIG_FILE"
    
    echo "$ITEM_BG_COLOR"
}

# Function to get label for current mode
get_mode_label() {
    # Mode is now the label itself
    local mode=$(cat "$MODE_FILE" 2>/dev/null || get_default_mode)
    echo "$mode"
}

# Function to get color name for a mode
get_mode_color_name() {
    local mode="$1"
    while IFS='|' read -r m icon color; do
        [[ "$m" =~ ^#.*$ ]] && continue
        [[ -z "$m" ]] && continue
        
        if [[ "$m" == "$mode" ]]; then
            echo "$color"
            return
        fi
    done < "$CONFIG_FILE"
    echo ""  # Default if not found
}

# Function to check if stopwatch is running (simplified)
is_running() {
    [ -f "$START_FILE" ]
}

# Function to update mode highlighting without re-rendering
update_mode_highlighting() {
    local old_mode="$1"
    local new_mode="$2"
    
    # Read through config to find indices and colors
    local index=0
    local old_index=-1
    local new_index=-1
    local new_color=""
    
    while IFS='|' read -r mode icon color; do
        # Skip comments/empty
        [[ "$mode" =~ ^#.*$ ]] && continue
        [[ -z "$mode" ]] && continue
        
        if [ "$mode" = "$old_mode" ]; then
            old_index=$index
        fi
        
        if [ "$mode" = "$new_mode" ]; then
            new_index=$index
            new_color="$color"
        fi
        
        index=$((index+1))
    done < "$CONFIG_FILE"
    
    # Update old mode to unselected appearance
    if [ $old_index -ge 0 ]; then
        sketchybar --set mode_option_$old_index \
                   background.color="${ITEM_BG_COLOR:-0x44000000}" \
                   icon.color="${LABEL_COLOR:-$WHITE}" \
                   label.color="${LABEL_COLOR:-$WHITE}"
    fi
    
    # Update new mode to selected appearance
    if [ $new_index -ge 0 ]; then
        # Get colors using mapping functions
        local bg_color=$(map_color_to_hex "$new_color")
        local text_color=$(get_text_color_for_background "$new_color")
        
        sketchybar --set mode_option_$new_index \
                   background.color="$bg_color" \
                   icon.color="$text_color" \
                   label.color="$text_color"
    fi
}

# Function to render mode options (integrated from render_stopwatch_modes.sh)
render_mode_options() {
    local action="${1:-show}"
    
    # Remove any existing mode option items
    for i in {0..30}; do
        sketchybar --remove mode_option_$i 2>/dev/null
    done
    
    # If just clearing, exit
    if [ "$action" = "clear" ]; then
        return
    fi
    
    # Determine current mode
    local current_mode=$(cat "$MODE_FILE" 2>/dev/null || get_default_mode)
    
    # Create mode option items
    local index=0
    while IFS='|' read -r mode icon color; do
        # Skip comments/empty
        [[ "$mode" =~ ^#.*$ ]] && continue
        [[ -z "$mode" ]] && continue
        
        # Get background color using mapping function
        local bg_color=$(map_color_to_hex "$color")
        
        # Set colors based on selection
        local bg_display text_color
        if [ "$mode" = "$current_mode" ]; then
            # Selected: use mode's color scheme
            bg_display="$bg_color"
            text_color=$(get_text_color_for_background "$color")
        else
            # Unselected: use default colors
            bg_display="${ITEM_BG_COLOR:-0x44000000}"
            text_color="${LABEL_COLOR:-$WHITE}"
        fi
        
        sketchybar --add item mode_option_$index center \
                   --set mode_option_$index \
                         icon="$icon" \
                         icon.color="$text_color" \
                         label="$mode" \
                         label.color="$text_color" \
                         background.color="$bg_display" \
                         background.drawing=on \
                         background.corner_radius=5 \
                         background.height=24 \
                         padding_left=5 \
                         padding_right=5 \
                         click_script="$CONFIG_DIR/plugins/stopwatch.sh cycle_mode $mode"
        
        index=$((index+1))
    done < "$CONFIG_FILE"
}

# Handle action based on parameter
case "$ACTION" in
    "tick")
        # New handler for sketchybar update events
        if [ -f "$START_FILE" ]; then
            START_TIME=$(cat "$START_FILE")
            CURRENT_TIME=$(date +%s)
            ELAPSED=$((CURRENT_TIME - START_TIME))
            
            # Format as HH:MM:SS
            HOURS=$((ELAPSED / 3600))
            MINUTES=$(( (ELAPSED % 3600) / 60 ))
            SECONDS=$((ELAPSED % 60))
            TIME_STR=$(printf "%02d:%02d:%02d" $HOURS $MINUTES $SECONDS)
            
            # Get the mode label to show with time
            MODE_LABEL=$(get_mode_label)
            
            sketchybar --set stopwatch label="$MODE_LABEL: $TIME_STR"
        fi
        ;;
        
    "click")
        # Toggle stopwatch start/stop
        if [ -f "$START_FILE" ]; then
            # Stopwatch is running - stop it
            echo "Stopping stopwatch"
            
            # Log the session
            start_time=$(cat "$START_FILE")
            end_time=$(date +%s)
            duration=$((end_time - start_time))
            
            # Only log if duration is at least 60 seconds
            if [ $duration -ge 60 ]; then
                log_session "$start_time" "$end_time" "$duration"
            fi
            
            # Clean up
            rm -f "$START_FILE"
            
            # Stop updates
            sketchybar --set stopwatch update_freq=0 \
                                      drawing=off \
                                      label="$(get_mode_label)" \
                                      background.color="$ITEM_BG_COLOR" \
                                      background.drawing=on \
                                      label.color="$WHITE" \
                                      icon.color="$WHITE"
            
            # Show idle mode options
            render_mode_options show
        else
            # Start new stopwatch
            echo "Starting stopwatch"
            date +%s > "$START_FILE"
            
            # Check current center view state
            CENTER_STATE_FILE="$CONFIG_DIR/.center_state"
            CURRENT_STATE=$(cat "$CENTER_STATE_FILE" 2>/dev/null || echo "0")
            
            # If not in stopwatch view (state 0), switch to it
            if [ "$CURRENT_STATE" != "0" ]; then
                bash "$CONFIG_DIR/plugins/toggle_center_view.sh"
            fi

            # Set the mode icon and background color
            ICON=$(get_mode_icon)
            COLOR=$(get_mode_color)
            MODE=$(cat "$MODE_FILE" 2>/dev/null || get_default_mode)

            # Get appropriate text color for the background
            MODE_COLOR_NAME=$(get_mode_color_name "$MODE")
            LABEL_COLOR=$(get_text_color_for_background "$MODE_COLOR_NAME")

            # Configure stopwatch appearance and start updates
            sketchybar --set stopwatch icon="$ICON" \
                                      background.color="$COLOR" \
                                      background.drawing=on \
                                      label.color="$LABEL_COLOR" \
                                      icon.color="$LABEL_COLOR" \
                                      drawing=on \
                                      update_freq=1

            # Clear idle mode options from center while running
            render_mode_options clear
        fi
        ;;
        
    "cycle_mode")
        # Handle mode selection from clicking mode options
        new_mode="$2"
        if [ -n "$new_mode" ]; then
            old_mode=$(cat "$MODE_FILE" 2>/dev/null || echo "ose")
            echo "$new_mode" > "$MODE_FILE"
            
            # Just update highlighting if items exist
            if sketchybar --query mode_option_0 &>/dev/null; then
                update_mode_highlighting "$old_mode" "$new_mode"
            else
                # Fallback to full render if items don't exist
                render_mode_options show
            fi
        fi
        ;;
        
    "next_mode")
        # Cycle to next mode (for keybindings)
        current_mode=$(cat "$MODE_FILE" 2>/dev/null || get_default_mode)
        
        # Get all modes in order
        modes=()
        while IFS='|' read -r mode rest; do
            [[ "$mode" =~ ^#.*$ ]] && continue
            [[ -z "$mode" ]] && continue
            modes+=("$mode")
        done < "$CONFIG_FILE"
        
        # Find current index and calculate next
        current_index=0
        for i in "${!modes[@]}"; do
            if [[ "${modes[$i]}" == "$current_mode" ]]; then
                current_index=$i
                break
            fi
        done
        
        # Get next mode (wrap around)
        next_index=$(( (current_index + 1) % ${#modes[@]} ))
        next_mode="${modes[$next_index]}"
        
        # Save new mode
        echo "$next_mode" > "$MODE_FILE"
        
        # If timer is idle, just update highlighting without re-rendering
        if [ ! -f "$START_FILE" ]; then
            # Update only the highlighting, not recreate items
            update_mode_highlighting "$current_mode" "$next_mode"
        fi
        ;;
        
    "render_modes")
        # Render mode options (called from other scripts)
        render_mode_options show
        ;;
        
    *)
        # Default to click for backward compatibility
        $0 click
        ;;
esac
