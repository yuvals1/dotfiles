#!/bin/bash

# Render all stopwatch modes in the center when the timer is idle.
# Highlights the currently selected mode.
# Usage:
#   render_stopwatch_modes.sh         # remove old and render all
#   render_stopwatch_modes.sh clear   # only remove all mode_option_* items

MODE_FILE="/tmp/sketchybar_stopwatch_mode"
CONFIG_DIR="$HOME/.config/sketchybar"
CONFIG_FILE="$CONFIG_DIR/stopwatch_modes.conf"

# Colors
source "$CONFIG_DIR/colors.sh" 2>/dev/null || true

# Helper: map color name to actual value
get_color_from_name() {
  local color_name="$1"
  case "$color_name" in
    "blue") echo "0xff4a90e2" ;;
    "red") echo "0xffff6b6b" ;;
    "yellow") echo "0xffffeb3b" ;;
    "green") echo "${GREEN:-0xff00ff00}" ;;
    "purple") echo "0xff9370db" ;;
    "teal") echo "${ACCENT_COLOR:-0xff00ffff}" ;;
    "orange") echo "${ORANGE:-0xffffa500}" ;;
    *) echo "${ITEM_BG_COLOR:-0x00000000}" ;;
  esac
}

# Remove any existing mode option items
remove_mode_items() {
  # Try removing a reasonable range
  for i in {0..30}; do
    sketchybar --remove mode_option_$i 2>/dev/null
  done
}

if [ "$1" = "clear" ]; then
  remove_mode_items
  exit 0
fi

# Determine current mode; fallback to first mode in config
CURRENT_MODE=$(cat "$MODE_FILE" 2>/dev/null)
if [ -z "$CURRENT_MODE" ]; then
  CURRENT_MODE=$(awk -F'|' '!/^#/ && NF >= 1 {print $1; exit}' "$CONFIG_FILE" 2>/dev/null)
fi

# Clear existing and (re)create
remove_mode_items

index=0
while IFS='|' read -r mode icon label color; do
  # Skip comments/empty
  [[ "$mode" =~ ^#.*$ ]] && continue
  [[ -z "$mode" ]] && continue

  bg_color=$(get_color_from_name "$color")

  # Selected highlighting
  border_width=0
  border_color="$WHITE"
  text_color="$WHITE"
  if [ "$color" = "yellow" ]; then
    text_color="$BLACK"
  fi
  if [ "$mode" = "$CURRENT_MODE" ]; then
    border_width=2
  fi

  sketchybar --add item mode_option_$index center \
             --set mode_option_$index \
                   icon="$icon" \
                   icon.color="$text_color" \
                   label="$label" \
                   label.color="$text_color" \
                   background.color="$bg_color" \
                   background.drawing=on \
                   background.corner_radius=5 \
                   background.height=24 \
                   background.border_color="$border_color" \
                   background.border_width=$border_width \
                   padding_left=5 \
                   padding_right=5

  index=$((index+1))
done < "$CONFIG_FILE"

exit 0
