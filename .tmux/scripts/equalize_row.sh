#!/bin/bash

# Get the current pane's position
current_pane=$(tmux display-message -p '#{pane_id}')
current_top=$(tmux display-message -p '#{pane_top}')
current_height=$(tmux display-message -p '#{pane_height}')
current_bottom=$((current_top + current_height))

# Get all panes in the current window with their positions
panes_in_row=""
while IFS= read -r line; do
    pane_id=$(echo "$line" | cut -d' ' -f1)
    pane_top=$(echo "$line" | cut -d' ' -f2)
    pane_height=$(echo "$line" | cut -d' ' -f3)
    pane_bottom=$((pane_top + pane_height))
    
    # Check if panes overlap vertically (are in the same row)
    if [ $pane_top -lt $current_bottom ] && [ $pane_bottom -gt $current_top ]; then
        panes_in_row="$panes_in_row $pane_id"
    fi
done < <(tmux list-panes -F '#{pane_id} #{pane_top} #{pane_height}')

# Count panes in the row
pane_count=$(echo $panes_in_row | wc -w)

if [ $pane_count -gt 1 ]; then
    # Calculate equal width for each pane
    window_width=$(tmux display-message -p '#{window_width}')
    # Account for pane borders (1 column between each pane)
    borders=$((pane_count - 1))
    available_width=$((window_width - borders))
    pane_width=$((available_width / pane_count))
    
    # Resize each pane in the row
    for pane in $panes_in_row; do
        tmux resize-pane -t "$pane" -x "$pane_width"
    done
fi