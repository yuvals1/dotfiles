#!/bin/bash

# Counting states plugin for sketchybar
# Tracks state transitions with timestamps - STATELESS version
# Just cycles through states with Alt+O and logs with Alt+U

CYCLE_INDEX_FILE="/tmp/sketchybar_counting_cycle_index"
CONFIG_FILE="$HOME/personal/tracking/counting_states.conf"
CONFIG_DIR="$HOME/.config/sketchybar"
TRACKING_DIR="$HOME/personal/tracking/state_logs"

# Source colors
source "$CONFIG_DIR/theme.sh"

# Handle different actions
ACTION="${1:-click}"

# Function to log state
log_state() {
    local state="$1"
    
    # Create tracking directory if it doesn't exist
    mkdir -p "$TRACKING_DIR"
    
    # Get date for filename
    local date_str=$(date '+%Y-%m-%d')
    local log_file="$TRACKING_DIR/${date_str}.log"
    
    # Format timestamp
    local timestamp=$(date '+%H:%M:%S')
    
    # Log entry format: TIMESTAMP | STATE
    echo "${timestamp} | ${state}" >> "$log_file"
}

# Function to map color names to hex values
map_color_to_hex() {
    local color_name="$1"
    case "$color_name" in
        "blue") echo "0xff4a90e2" ;;
        "red") echo "0xffff6b6b" ;;
        "yellow") echo "0xffffeb3b" ;;
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
    case "$color_name" in
        "yellow"|"white"|"light-blue"|"light-green") 
            echo "$BLACK" ;;
        *)
            echo "$WHITE" ;;
    esac
}

# Function to get all states as array
get_all_states() {
    local states=()
    while IFS='|' read -r state icon color; do
        [[ "$state" =~ ^#.*$ ]] && continue
        [[ -z "$state" ]] && continue
        states+=("$state|$icon|$color")
    done < "$CONFIG_FILE"
    printf '%s\n' "${states[@]}"
}

# Function to count state occurrences for today
count_state_today() {
    local state_name="$1"
    local date_str=$(date '+%Y-%m-%d')
    local log_file="$TRACKING_DIR/${date_str}.log"
    
    if [ -f "$log_file" ]; then
        # Count lines that end with the state name
        grep " | ${state_name}$" "$log_file" 2>/dev/null | wc -l | tr -d ' '
    else
        echo "0"
    fi
}

# Function to render state options (no selection highlighting)
render_state_options() {
    local action="${1:-show}"
    
    # Remove any existing state option items
    for i in {0..30}; do
        sketchybar --remove state_option_$i 2>/dev/null
    done
    
    # If just clearing, exit
    if [ "$action" = "clear" ]; then
        return
    fi
    
    # Get current cycle index to show which state we're on
    local current_index=$(cat "$CYCLE_INDEX_FILE" 2>/dev/null || echo "0")
    
    # Create state option items
    local index=0
    while IFS='|' read -r state icon color; do
        [[ "$state" =~ ^#.*$ ]] && continue
        [[ -z "$state" ]] && continue
        
        # Get count for this state
        local count=$(count_state_today "$state")
        
        # Get background color
        local bg_color=$(map_color_to_hex "$color")
        local text_color=$(get_text_color_for_background "$color")
        
        # Highlight the one we're currently cycled to (not "selected", just current position)
        local bg_display
        if [ $index -eq $current_index ]; then
            # Current position in cycle - show with color
            bg_display="$bg_color"
        else
            # Not current position - default background
            bg_display="${ITEM_BG_COLOR:-0x44000000}"
            text_color="${LABEL_COLOR:-$WHITE}"
        fi
        
        # Add count to label
        local label_text="$state ($count)"
        
        sketchybar --add item state_option_$index center \
                   --set state_option_$index \
                         icon="$icon" \
                         icon.color="$text_color" \
                         label="$label_text" \
                         label.color="$text_color" \
                         background.color="$bg_display" \
                         background.drawing=on \
                         background.corner_radius=5 \
                         background.height=24 \
                         padding_left=5 \
                         padding_right=5 \
                         click_script="$CONFIG_DIR/plugins/counting_states.sh log_index $index"
        
        index=$((index+1))
    done < "$CONFIG_FILE"
}

# Function to update highlighting for current cycle position
update_cycle_highlighting() {
    local old_index="$1"
    local new_index="$2"
    
    # Read states to get colors
    local states=()
    while IFS='|' read -r state icon color; do
        [[ "$state" =~ ^#.*$ ]] && continue
        [[ -z "$state" ]] && continue
        states+=("$color")
    done < "$CONFIG_FILE"
    
    # Unhighlight old position
    if [ "$old_index" -ge 0 ] && sketchybar --query state_option_$old_index &>/dev/null; then
        sketchybar --set state_option_$old_index \
                   background.color="${ITEM_BG_COLOR:-0x44000000}" \
                   icon.color="${LABEL_COLOR:-$WHITE}" \
                   label.color="${LABEL_COLOR:-$WHITE}"
    fi
    
    # Highlight new position
    if [ "$new_index" -ge 0 ] && [ "$new_index" -lt ${#states[@]} ]; then
        color="${states[$new_index]}"
        bg_color=$(map_color_to_hex "$color")
        text_color=$(get_text_color_for_background "$color")
        
        sketchybar --set state_option_$new_index \
                   background.color="$bg_color" \
                   icon.color="$text_color" \
                   label.color="$text_color"
    fi
}

# Handle action based on parameter
case "$ACTION" in
    "update")
        # Nothing to update - stateless
        ;;
        
    "select"|"log")
        # Log the state at current cycle position
        current_index=$(cat "$CYCLE_INDEX_FILE" 2>/dev/null || echo "0")
        
        # Get state at current index
        index=0
        while IFS='|' read -r state icon color; do
            [[ "$state" =~ ^#.*$ ]] && continue
            [[ -z "$state" ]] && continue
            
            if [ $index -eq $current_index ]; then
                log_state "$state"
                
                # Visual feedback - brief flash
                if sketchybar --query state_option_$index &>/dev/null; then
                    sketchybar --set state_option_$index background.color="0xffffffff"
                    sleep 0.1
                    # Re-render to update counts
                    render_state_options show
                fi
                break
            fi
            index=$((index+1))
        done < "$CONFIG_FILE"
        ;;
        
    "log_index")
        # Log state at specific index (for click handling)
        target_index="$2"
        index=0
        while IFS='|' read -r state icon color; do
            [[ "$state" =~ ^#.*$ ]] && continue
            [[ -z "$state" ]] && continue
            
            if [ $index -eq $target_index ]; then
                log_state "$state"
                
                # Update cycle position to clicked item
                echo "$target_index" > "$CYCLE_INDEX_FILE"
                
                # Visual feedback
                if sketchybar --query state_option_$index &>/dev/null; then
                    sketchybar --set state_option_$index background.color="0xffffffff"
                    sleep 0.1
                    render_state_options show
                fi
                break
            fi
            index=$((index+1))
        done < "$CONFIG_FILE"
        ;;
        
    "next_state")
        # Cycle to next state position
        current_index=$(cat "$CYCLE_INDEX_FILE" 2>/dev/null || echo "0")
        
        # Count total states
        total_states=0
        while IFS='|' read -r state icon color; do
            [[ "$state" =~ ^#.*$ ]] && continue
            [[ -z "$state" ]] && continue
            total_states=$((total_states+1))
        done < "$CONFIG_FILE"
        
        # Calculate next index
        next_index=$(( (current_index + 1) % total_states ))
        
        # Save new index
        echo "$next_index" > "$CYCLE_INDEX_FILE"
        
        # Update highlighting
        if sketchybar --query state_option_0 &>/dev/null; then
            update_cycle_highlighting "$current_index" "$next_index"
        fi
        ;;
        
    "render_states")
        # Render state options (called from other scripts)
        render_state_options show
        ;;
        
    *)
        # Default to select for backward compatibility
        $0 select
        ;;
esac