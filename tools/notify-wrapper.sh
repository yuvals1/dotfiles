#!/bin/bash
# Wrapper to run notify in background and exit immediately

"$HOME/.local/bin/notify" "$@" &
exit 0