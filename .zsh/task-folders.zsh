#!/bin/zsh
# Task folder configuration for yazi task management

# Base directory for all tasks (can be overridden in .zshrc or .zshenv)
export TASK_BASE_DIR="${TASK_BASE_DIR:-$HOME/tasks}"

# Task folder names
export TASK_PROGRESS="in-progress"
export TASK_WAITING="waiting"
export TASK_BACKLOG="backlog"
export TASK_DONE="done"

# Full paths for each task folder
export TASK_PROGRESS_PATH="$TASK_BASE_DIR/$TASK_PROGRESS"
export TASK_WAITING_PATH="$TASK_BASE_DIR/$TASK_WAITING"
export TASK_BACKLOG_PATH="$TASK_BASE_DIR/$TASK_BACKLOG"
export TASK_DONE_PATH="$TASK_BASE_DIR/$TASK_DONE"

# Task management functions for yazi

task_move_backlog() {
  mkdir -p "$TASK_BACKLOG_PATH" && mv "$1" "$TASK_BACKLOG_PATH"/
}

task_move_done() {
  mkdir -p "$TASK_DONE_PATH" && mv "$1" "$TASK_DONE_PATH"/
}

task_move_progress() {
  mkdir -p "$TASK_PROGRESS_PATH" && mv "$1" "$TASK_PROGRESS_PATH"/
}

task_move_waiting() {
  mkdir -p "$TASK_WAITING_PATH" && mv "$1" "$TASK_WAITING_PATH"/
}
