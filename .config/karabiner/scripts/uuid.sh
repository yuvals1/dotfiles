#!/bin/bash
uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | tr -d '\n' | pbcopy
osascript -e 'tell application "System Events" to keystroke (the clipboard as text)'
