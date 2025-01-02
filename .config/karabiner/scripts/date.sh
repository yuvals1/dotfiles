#!/bin/bash
date "+%d/%m/%Y" | tr -d '\n' | pbcopy
osascript -e 'tell application "System Events" to keystroke (the clipboard as text)'
