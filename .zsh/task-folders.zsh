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
