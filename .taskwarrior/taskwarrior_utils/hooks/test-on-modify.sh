#!/bin/bash

# important note:
# you can also just run:
# ❯ echo -e '{}\n{"start": "20241012T120000Z", "uuid": "4", "description": "Test task", "tags": ["tag1", "tag2"]}' | ./on-modify.timewarrior

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Path to the on-modify.timewarrior script
SCRIPT_PATH="$SCRIPT_DIR/on-modify.timewarrior"

# Test case 1: Starting a task
echo "Test Case 1: Starting a task"
echo -e '{}\n{"start": "20241012T120000Z", "uuid": "4", "description": "Test task", "tags": ["tag1", "tag2"]}' | $SCRIPT_PATH
echo

# Test case 2: Modifying a running task
echo "Test Case 2: Modifying a running task"
echo -e '{"start": "20241012T120000Z", "uuid": "4", "description": "Test task", "tags": ["tag1"]}\n{"start": "20241012T120000Z", "uuid": "4", "description": "Modified test task", "tags": ["tag1", "tag2"]}' | $SCRIPT_PATH
echo

# Test case 3: Stopping a task
echo "Test Case 3: Stopping a task"
echo -e '{"start": "20241012T120000Z", "uuid": "4", "description": "Test task", "tags": ["tag1", "tag2"]}\n{"start": "20241012T120000Z", "end": "20241012T130000Z", "uuid": "4", "description": "Test task", "tags": ["tag1", "tag2"]}' | $SCRIPT_PATH
echo

# Add more test cases as needed
