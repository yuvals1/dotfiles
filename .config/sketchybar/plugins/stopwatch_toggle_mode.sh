#!/bin/bash

# Toggle between stopwatch modes defined in config file

MODE_FILE="/tmp/sketchybar_stopwatch_mode"
CONFIG_DIR="$HOME/.config/sketchybar"
CONFIG_FILE="$CONFIG_DIR/stopwatch_modes.conf"

# Read all modes from config
MODES=()
ICONS=()
LABELS=()

while IFS='|' read -r mode icon label; do
    # Skip comments and empty lines
    [[ "$mode" =~ ^#.*$ ]] && continue
    [[ -z "$mode" ]] && continue
    
    MODES+=("$mode")
    ICONS+=("$icon")
    LABELS+=("$label")
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

# Update icon in sketchybar
sketchybar --set stopwatch icon="$NEW_ICON"

# Check if stopwatch is running
PID_FILE="/tmp/sketchybar_stopwatch.pid"
if [ ! -f "$PID_FILE" ]; then
    # Not running - just show the new mode label (no need to revert)
    sketchybar --set stopwatch label="$NEW_LABEL"
fi

# Show brief notification of mode change
echo "Mode: $NEW_LABEL"