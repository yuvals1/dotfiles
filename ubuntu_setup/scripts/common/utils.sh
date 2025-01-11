#!/usr/bin/env bash
#
# Common utility functions reused across multiple scripts.

# Checks if a command exists on the PATH
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

