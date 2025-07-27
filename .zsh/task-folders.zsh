#!/bin/zsh
# Task folder names for yazi task management

export TASK_PROGRESS="1-⭐ in-progress"
export TASK_BACKLOG="2-📦 backlog"
export TASK_DONE="3-✅ done"

# Task management functions for yazi

task_move_backlog() {
  mkdir -p ~/tasks/"$TASK_BACKLOG" && mv "$1" ~/tasks/"$TASK_BACKLOG"/
}

task_move_done() {
  mkdir -p ~/tasks/"$TASK_DONE" && mv "$1" ~/tasks/"$TASK_DONE"/
}

task_move_progress() {
  mkdir -p ~/tasks/"$TASK_PROGRESS" && mv "$1" ~/tasks/"$TASK_PROGRESS"/
}

# Common function to add emoji label to task file
task_add_emoji_label() {
  local file="$1"
  local emoji="$2"
  local label="$3"
  
  if [ -f "$file" ]; then
    # Update Label in file
    sed -i "" "s/^Label:.*/Label: $label/" "$file"
    
    # Get original timestamp
    timestamp=$(stat -f "%m" "$file")
    
    # Rename file with emoji prefix
    base=$(basename "$file")
    dir=$(dirname "$file")
    # Remove any existing emoji prefix
    base_clean=$(echo "$base" | sed -E "s/^[🧨🟢🔴] //")
    new_path="$dir/$emoji $base_clean"
    
    # Only rename if needed
    if [ "$file" != "$new_path" ]; then
      mv "$file" "$new_path"
      # Restore original timestamp
      touch -t $(date -r $timestamp "+%Y%m%d%H%M.%S") "$new_path"
    fi
  fi
}

# Task labeling functions
task_mark_important() {
  for file in "$@"; do
    task_add_emoji_label "$file" "🧨" "🧨"
  done
}

task_mark_ready() {
  for file in "$@"; do
    task_add_emoji_label "$file" "🟢" "🟢"
  done
}

task_mark_waiting() {
  for file in "$@"; do
    task_add_emoji_label "$file" "🔴" "🔴"
  done
}
