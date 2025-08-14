#!/bin/bash

# Toggle between stopwatch modes defined in config file

MODE_FILE="/tmp/sketchybar_stopwatch_mode"
PID_FILE="/tmp/sketchybar_stopwatch.pid"
CONFIG_DIR="$HOME/.config/sketchybar"
CONFIG_FILE="$CONFIG_DIR/stopwatch_modes.conf"

# If stopwatch is running - don't allow mode change, keep current behavior
if [ -f "$PID_FILE" ]; then
    echo "Cannot change mode while stopwatch is running"
    exit 0
fi

# Read all modes from config
MODES=()
ICONS=()
LABELS=()
COLORS=()

while IFS='|' read -r mode icon label color; do
    # Skip comments and empty lines
    [[ "$mode" =~ ^#.*$ ]] && continue
    [[ -z "$mode" ]] && continue
    
    MODES+=("$mode")
    ICONS+=("$icon")
    LABELS+=("$label")
    COLORS+=("$color")
done < "$CONFIG_FILE"

# Get current mode index
CURRENT_MODE=$(cat "$MODE_FILE" 2>/dev/null || echo "work")
CURRENT_INDEX=0

for i in "${!MODES[@]}"; do
    if [[ "${MODES[$i]}" == "$CURRENT_MODE" ]]; then
        CURRENT_INDEX=$i
        break
    fi
done

# Calculate next index (cycle through modes)
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#MODES[@]} ))

# Save new mode
NEW_MODE="${MODES[$NEXT_INDEX]}"
NEW_ICON="${ICONS[$NEXT_INDEX]}"
NEW_LABEL="${LABELS[$NEXT_INDEX]}"

echo "$NEW_MODE" > "$MODE_FILE"

# Update selection in idle view without full re-render
if sketchybar --query mode_option_0 &>/dev/null; then
    # Opacity focus: selected full opacity, others dimmed
    # We need the color name for each mode to rebuild the correct alpha; re-read the config
    # Build associative arrays (by index) for colors
    COLORS_BY_INDEX=()
    idx=0
    while IFS='|' read -r m icon label color; do
        [[ "$m" =~ ^#.*$ ]] && continue
        [[ -z "$m" ]] && continue
        COLORS_BY_INDEX[$idx]="$color"
        idx=$((idx+1))
    done < "$CONFIG_FILE"

    # Helper to map color name
    map_color() {
        case "$1" in
            blue) echo 0xff4a90e2 ;;
            red) echo 0xffff6b6b ;;
            yellow) echo 0xffffeb3b ;;
            green) echo ${GREEN:-0xff00ff00} ;;
            purple) echo 0xff9370db ;;
            teal) echo ${ACCENT_COLOR:-0xff00ffff} ;;
            orange) echo ${ORANGE:-0xffffa500} ;;
            *) echo ${ITEM_BG_COLOR:-0x00000000} ;;
        esac
    }

    set_alpha() {
        local color="$1"
        local alpha="$2"
        local tail="${color:4}"
        echo "0x${alpha}${tail}"
    }

    # Load colors from config
    source "$CONFIG_DIR/colors.sh" 2>/dev/null || true
    
    next_color_name="${COLORS_BY_INDEX[$NEXT_INDEX]}"
    next_color=$(map_color "$next_color_name")
    default_bg="${ITEM_BG_COLOR:-0x44000000}"

    # Previous selected becomes default (unselected)
    default_text="${LABEL_COLOR:-$WHITE}"
    sketchybar --set mode_option_${CURRENT_INDEX} \
        background.color="$default_bg" \
        icon.color="$default_text" \
        label.color="$default_text" 2>/dev/null
    
    # Next becomes selected with its color and appropriate text
    selected_text="$WHITE"
    if [ "$next_color_name" = "yellow" ]; then
        selected_text="$BLACK"
    fi
    sketchybar --set mode_option_${NEXT_INDEX} \
        background.color="$next_color" \
        icon.color="$selected_text" \
        label.color="$selected_text" 2>/dev/null
else
    # If the list isn't present, render it once
    bash "$CONFIG_DIR/plugins/render_stopwatch_modes.sh"
fi

# Show brief notification of mode change
echo "Mode: $NEW_LABEL"