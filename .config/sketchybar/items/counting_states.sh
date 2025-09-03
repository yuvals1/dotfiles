#!/bin/bash

# Source colors and icons
source "$HOME/.config/sketchybar/theme.sh"

# Counting states icon that shows when in counting view (state 2)
sketchybar --add item counting_states_icon center \
           --set counting_states_icon icon="📊" \
                               icon.color=$WHITE \
                               icon.font="SF Pro:Regular:18.0" \
                               label="State Logger" \
                               label.color=$WHITE \
                               padding_left=8 \
                               padding_right=8 \
                               drawing=off

# Note: No persistent state display - we just show the state options
# The counting_states item is just a placeholder for the toggle_center_view script
sketchybar --add item counting_states center \
           --set counting_states drawing=off