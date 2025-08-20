#!/usr/bin/env bash

# Store the state in a tmux variable
current_state=$(tmux show-options -wqv @layout_toggle_state)

if [ "$current_state" = "vertical" ]; then
    tmux select-layout even-horizontal
    tmux set-option -w @layout_toggle_state "horizontal"
else
    tmux select-layout even-vertical
    tmux set-option -w @layout_toggle_state "vertical"
fi