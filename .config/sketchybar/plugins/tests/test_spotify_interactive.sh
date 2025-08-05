#!/bin/bash

echo "=== Interactive Spotify Wrapper Tests ==="
echo
echo "These tests require manual verification:"
echo

echo "Test A: Alt+I Response"
echo "1. Press Alt+I multiple times rapidly"
echo "2. Music should pause/play immediately each time"
echo "3. No delays or hanging"
echo
read -p "Press Enter when ready to continue..."
echo

echo "Test B: Radio Cycling (Alt+R)"
echo "1. Press Alt+R to cycle through radio modes"
echo "2. Each press should change the mode immediately"
echo "3. Display should update within 1 second"
echo
read -p "Press Enter when ready to continue..."
echo

echo "Test C: Concurrent Usage"
echo "1. Open spotify_player TUI in another terminal"
echo "2. Press Alt+I, Alt+R, etc while TUI is open"
echo "3. TUI should NOT be killed"
echo "4. Commands should still work"
echo
read -p "Press Enter when ready to continue..."
echo

echo "Test D: Display Updates"
echo "1. Play a song"
echo "2. The display should update every second"
echo "3. Press Alt+N to skip to next track"
echo "4. Display should update immediately (not wait for next poll)"
echo
read -p "Press Enter when ready to continue..."
echo

echo "Test E: Process Count"
echo "Checking current spotify_player processes..."
ps aux | grep spotify_player | grep -v grep | wc -l
echo "Expected: 1 (daemon only) or 2 (daemon + TUI)"
echo
echo "API command processes:"
ps aux | grep spotify_player | grep -E "get|playback|play|search" | grep -v grep | wc -l
echo "Expected: 0"