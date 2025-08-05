#!/bin/bash

echo "=== Spotify Smart Wrapper Test Suite ==="
echo

# Test 1: Basic play/pause response time
echo "Test 1: Play/pause response time"
echo "Expected: < 100ms"
echo -n "Result: "
time /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_keyboard.sh play-pause 2>&1 | grep real
echo

# Test 2: Concurrent commands from different sources
echo "Test 2: Different sources shouldn't interfere"
echo "Starting background display update..."
SPOTIFY_SOURCE=display /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh get key playback &
DISPLAY_PID=$!
sleep 0.1

echo "Pressing play/pause (should not kill display command)..."
/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_keyboard.sh play-pause

# Check if display command is still running
if kill -0 $DISPLAY_PID 2>/dev/null; then
    echo "✓ PASS: Display command still running"
    kill $DISPLAY_PID 2>/dev/null
else
    echo "✗ FAIL: Display command was killed"
fi
echo

# Test 3: Same source, same type - should kill previous
echo "Test 3: Same source/type should kill previous"
echo "Starting first play/pause..."
SPOTIFY_SOURCE=keyboard /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh playback play-pause &
FIRST_PID=$!
sleep 0.1

echo "Starting second play/pause (should kill first)..."
SPOTIFY_SOURCE=keyboard /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh playback play-pause &
SECOND_PID=$!
sleep 0.1

if kill -0 $FIRST_PID 2>/dev/null; then
    echo "✗ FAIL: First command still running"
    kill $FIRST_PID 2>/dev/null
else
    echo "✓ PASS: First command was killed"
fi
kill $SECOND_PID 2>/dev/null
echo

# Test 4: Same source, different type - should NOT kill
echo "Test 4: Same source, different type shouldn't interfere"
echo "Starting play/pause..."
SPOTIFY_SOURCE=keyboard /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh playback play-pause &
PLAY_PID=$!
sleep 0.1

echo "Starting next track (different type)..."
SPOTIFY_SOURCE=keyboard /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh playback next &
NEXT_PID=$!
sleep 0.1

if kill -0 $PLAY_PID 2>/dev/null; then
    echo "✓ PASS: Play/pause still running"
    kill $PLAY_PID 2>/dev/null
else
    echo "✗ FAIL: Play/pause was killed"
fi
kill $NEXT_PID 2>/dev/null
echo

# Test 5: Marker file cleanup
echo "Test 5: Marker files cleanup"
MARKER_DIR="/Users/yuvalspiegel/.config/sketchybar/.spotify_markers"
rm -f $MARKER_DIR/* 2>/dev/null

/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_keyboard.sh play-pause
sleep 0.5

MARKERS=$(ls $MARKER_DIR 2>/dev/null | wc -l)
if [ "$MARKERS" -eq 0 ]; then
    echo "✓ PASS: All marker files cleaned up"
else
    echo "✗ FAIL: $MARKERS marker files still exist"
    ls $MARKER_DIR
fi
echo

# Test 6: Rapid fire commands
echo "Test 6: Rapid fire commands (10 play/pause in quick succession)"
START_TIME=$(date +%s)
for i in {1..10}; do
    /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_keyboard.sh play-pause &
done
wait
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

if [ "$DURATION" -le 2 ]; then
    echo "✓ PASS: Completed in ${DURATION}s (should be < 2s)"
else
    echo "✗ FAIL: Took ${DURATION}s (too slow)"
fi
echo

# Test 7: Check for hanging processes
echo "Test 7: No hanging spotify_player processes"
HANGING=$(pgrep -f "spotify_player.*get\|playback\|play\|search" | wc -l)
if [ "$HANGING" -eq 0 ]; then
    echo "✓ PASS: No hanging processes"
else
    echo "✗ FAIL: Found $HANGING hanging processes"
    ps aux | grep spotify_player | grep -E "get|playback|play|search" | grep -v grep
fi