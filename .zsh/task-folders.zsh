#!/bin/zsh
# Task folder names for yazi task management

export TASK_BACKLOG="1-📋 backlog"
export TASK_READY="2-🟢 ready"
export TASK_PROGRESS="3-⭐ in-progress"
export TASK_WAITING="4-🔴 waiting"
export TASK_IMPORTANT="5-❗ important"
export TASK_DONE="6-✅ done"

# Task management functions for yazi

task_move_done() {
  local file="$1"
  local actual_file="$file"
  
  # If it's a symlink, get the actual file
  if [ -L "$file" ]; then
    actual_file=$(readlink -f "$file")
    # Remove the symlink first
    rm -f "$file"
  fi
  
  local task_name=$(basename "$actual_file")
  local current_task=$(ls -1 ~/.config/sketchybar/pomodoro/current-task/ 2>/dev/null | head -1)
  
  if [ "$current_task" = "$task_name" ]; then
    ~/.config/sketchybar/task-link clear
  fi
  
  # Move the actual file (not the symlink) to done
  mkdir -p ~/tasks/"$TASK_DONE" && mv "$actual_file" ~/tasks/"$TASK_DONE"/
  
  # Clean up any broken symlinks after moving
  find ~/tasks -type l ! -exec test -e {} \; -delete 2>/dev/null
}

task_move_backlog() {
  mkdir -p ~/tasks/"$TASK_BACKLOG" && mv "$1" ~/tasks/"$TASK_BACKLOG"/
}

task_toggle_important() {
  local file="$1"
  local dir=$(dirname "$file")
  local base=$(basename "$file")
  
  if [[ "$base" =~ ^❗ ]]; then
    # Remove important marker
    local new_name="${base#❗ }"
    mv "$file" "$dir/$new_name"
    rm -f ~/tasks/"$TASK_IMPORTANT/$base"
    echo "Removed important marker from: $new_name"
  else
    # Add important marker
    local new_name="❗ $base"
    mv "$file" "$dir/$new_name"
    mkdir -p ~/tasks/"$TASK_IMPORTANT"
    ln -sf "$dir/$new_name" ~/tasks/"$TASK_IMPORTANT/"
    echo "Marked as important: $new_name"
  fi
}

task_toggle_ready() {
  local file="$1"
  local dir=$(dirname "$file")
  local base=$(basename "$file")
  
  mkdir -p ~/tasks/"$TASK_READY" ~/tasks/"$TASK_WAITING"
  
  if [[ "$base" =~ ^🔴 ]]; then
    # Change from blocked to ready
    local new_name="${base#🔴 }"
    new_name="🟢 $new_name"
    mv "$file" "$dir/$new_name"
    rm -f ~/tasks/"$TASK_WAITING/$base"
    ln -sf "$dir/$new_name" ~/tasks/"$TASK_READY/"
    echo "Task marked as ready: $new_name"
  elif [[ "$base" =~ ^🟢 ]]; then
    # Change from ready to blocked
    local new_name="${base#🟢 }"
    new_name="🔴 $new_name"
    mv "$file" "$dir/$new_name"
    rm -f ~/tasks/"$TASK_READY/$base"
    ln -sf "$dir/$new_name" ~/tasks/"$TASK_WAITING/"
    echo "Task marked as blocked: $new_name"
  else
    # No status - mark as ready
    local new_name="🟢 $base"
    mv "$file" "$dir/$new_name"
    ln -sf "$dir/$new_name" ~/tasks/"$TASK_READY/"
    echo "Task marked as ready: $new_name"
  fi
}

task_clean_symlinks() {
  local count=$(find ~/tasks -type l ! -exec test -e {} \; -delete -print | wc -l)
  echo "Cleaned up $count broken symlinks in ~/tasks"
}