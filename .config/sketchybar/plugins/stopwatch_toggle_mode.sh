#!/bin/bash

# Toggle between stopwatch modes defined in config file

MODE_FILE="/tmp/sketchybar_stopwatch_mode"
PID_FILE="/tmp/sketchybar_stopwatch.pid"
CONFIG_DIR="$HOME/.config/sketchybar"
CONFIG_FILE="$CONFIG_DIR/stopwatch_modes.conf"

# Check if stopwatch is running - don't allow mode change
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

# Update icon and label in sketchybar
sketchybar --set stopwatch icon="$NEW_ICON" \
                          label="$NEW_LABEL"

# Show brief notification of mode change
echo "Mode: $NEW_LABEL"