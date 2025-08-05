#!/bin/bash

# Radio state management functions
# States: 0=Normal, 1=Track Radio, 2=Artist Radio, 3=Album Radio, 4=Playlist Radio

RADIO_STATE_FILE="$HOME/.config/sketchybar/.spotify_radio_state"
RADIO_SEED_FILE="$HOME/.config/sketchybar/.spotify_radio_seed"

# Get current radio state (default to 0 if file doesn't exist)
get_radio_state() {
    if [ -f "$RADIO_STATE_FILE" ]; then
        cat "$RADIO_STATE_FILE"
    else
        echo "0"
    fi
}

# Set radio state
set_radio_state() {
    local state="$1"
    echo "$state" > "$RADIO_STATE_FILE"
}

# Get radio state label
get_radio_label() {
    local state="$1"
    case "$state" in
        1) echo "Track Radio" ;;
        2) echo "Artist Radio" ;;
        3) echo "Album Radio" ;;
        4) echo "Playlist Radio" ;;
        *) echo "" ;;
    esac
}

# Reset to normal playback (state 0)
reset_radio_state() {
    set_radio_state "0"
    rm -f "$RADIO_SEED_FILE"
}

# Set radio seed name
set_radio_seed() {
    local seed="$1"
    echo "$seed" > "$RADIO_SEED_FILE"
}

# Get radio seed name
get_radio_seed() {
    if [ -f "$RADIO_SEED_FILE" ]; then
        cat "$RADIO_SEED_FILE"
    else
        echo ""
    fi
}