#!/bin/bash

# Get the current pane's position
current_pane=$(tmux display-message -p '#{pane_id}')
current_left=$(tmux display-message -p '#{pane_left}')
current_width=$(tmux display-message -p '#{pane_width}')
current_right=$((current_left + current_width))

# Get all panes in the current window with their positions
panes_in_column=""
while IFS= read -r line; do
    pane_id=$(echo "$line" | cut -d' ' -f1)
    pane_left=$(echo "$line" | cut -d' ' -f2)
    pane_width=$(echo "$line" | cut -d' ' -f3)
    pane_right=$((pane_left + pane_width))
    
    # Check if panes overlap horizontally (are in the same column)
    if [ $pane_left -lt $current_right ] && [ $pane_right -gt $current_left ]; then
        panes_in_column="$panes_in_column $pane_id"
    fi
done < <(tmux list-panes -F '#{pane_id} #{pane_left} #{pane_width}')

# Count panes in the column
pane_count=$(echo $panes_in_column | wc -w)

if [ $pane_count -gt 1 ]; then
    # Calculate equal height for each pane
    window_height=$(tmux display-message -p '#{window_height}')
    # Account for pane borders (1 line between each pane)
    borders=$((pane_count - 1))
    available_height=$((window_height - borders))
    pane_height=$((available_height / pane_count))
    
    # Resize each pane in the column
    for pane in $panes_in_column; do
        tmux resize-pane -t "$pane" -y "$pane_height"
    done
fi