#!/usr/bin/env bash

# Get current layout cycle state from tmux variable
current_state=$(tmux show-options -wqv @layout_cycle_state)

# Cycle through: grid -> horizontal -> vertical -> grid
case "$current_state" in
    "horizontal")
        tmux select-layout even-vertical
        tmux set-option -w @layout_cycle_state "vertical"
        ;;
    "vertical")
        tmux select-layout tiled
        tmux set-option -w @layout_cycle_state "grid"
        ;;
    *)
        # Default to horizontal (includes "grid" state or undefined)
        tmux select-layout even-horizontal
        tmux set-option -w @layout_cycle_state "horizontal"
        ;;
esac