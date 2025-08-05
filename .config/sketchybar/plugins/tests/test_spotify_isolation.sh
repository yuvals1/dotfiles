#!/bin/bash

echo "=== Spotify Wrapper Isolation Test ==="
echo "This tests that commands are properly isolated by source and type"
echo

MARKER_DIR="/Users/yuvalspiegel/.config/sketchybar/.spotify_markers"

# Helper function to check if process is alive
is_alive() {
    kill -0 $1 2>/dev/null
}

# Test 1: Display commands shouldn't affect keyboard commands
echo "Test 1: Display vs Keyboard isolation"
rm -f $MARKER_DIR/* 2>/dev/null

# Start a long-running display command
SPOTIFY_SOURCE=display /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh get key playback >/dev/null 2>&1 &
DISPLAY_PID=$!
sleep 0.1

# Run keyboard command
SPOTIFY_SOURCE=keyboard /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh playback play-pause >/dev/null 2>&1

# Check if display command survived
if is_alive $DISPLAY_PID; then
    echo "✓ PASS: Display command survived keyboard command"
    kill $DISPLAY_PID 2>/dev/null
else
    echo "✗ FAIL: Display command was killed by keyboard command"
fi
echo

# Test 2: Different command types from same source
echo "Test 2: Same source, different command types"
rm -f $MARKER_DIR/* 2>/dev/null

# Start play-pause
SPOTIFY_SOURCE=keyboard /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh playback play-pause >/dev/null 2>&1 &
PLAY_PID=$!
sleep 0.1

# Start next (different type)
SPOTIFY_SOURCE=keyboard /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh playback next >/dev/null 2>&1 &
NEXT_PID=$!
sleep 0.1

# Both should be alive
PLAY_ALIVE=$(is_alive $PLAY_PID && echo "YES" || echo "NO")
NEXT_ALIVE=$(is_alive $NEXT_PID && echo "YES" || echo "NO")

if [ "$PLAY_ALIVE" = "YES" ] && [ "$NEXT_ALIVE" = "YES" ]; then
    echo "✓ PASS: Different command types coexist"
else
    echo "✗ FAIL: Commands interfered (play=$PLAY_ALIVE, next=$NEXT_ALIVE)"
fi
kill $PLAY_PID $NEXT_PID 2>/dev/null
echo

# Test 3: Radio commands isolation
echo "Test 3: Radio source isolation"
rm -f $MARKER_DIR/* 2>/dev/null

# Start radio command
SPOTIFY_SOURCE=radio /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh playback start radio --id abc track >/dev/null 2>&1 &
RADIO_PID=$!
sleep 0.1

# Run display and keyboard commands
SPOTIFY_SOURCE=display /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh get key playback >/dev/null 2>&1 &
DISPLAY_PID=$!
SPOTIFY_SOURCE=keyboard /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh playback play-pause >/dev/null 2>&1 &
KEYBOARD_PID=$!
sleep 0.1

# All should be alive
RADIO_ALIVE=$(is_alive $RADIO_PID && echo "YES" || echo "NO")
DISPLAY_ALIVE=$(is_alive $DISPLAY_PID && echo "YES" || echo "NO")
KEYBOARD_ALIVE=$(is_alive $KEYBOARD_PID && echo "YES" || echo "NO")

if [ "$RADIO_ALIVE" = "YES" ] && [ "$DISPLAY_ALIVE" = "YES" ] && [ "$KEYBOARD_ALIVE" = "YES" ]; then
    echo "✓ PASS: All sources properly isolated"
else
    echo "✗ FAIL: Source isolation failed (radio=$RADIO_ALIVE, display=$DISPLAY_ALIVE, keyboard=$KEYBOARD_ALIVE)"
fi
kill $RADIO_PID $DISPLAY_PID $KEYBOARD_PID 2>/dev/null
echo

# Test 4: Verify marker naming convention
echo "Test 4: Marker file naming"
rm -f $MARKER_DIR/* 2>/dev/null

SPOTIFY_SOURCE=keyboard /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh playback play-pause >/dev/null 2>&1 &
TEST_PID=$!
sleep 0.1

MARKER=$(ls $MARKER_DIR/keyboard_playback_play-pause_* 2>/dev/null | head -1)
if [ -n "$MARKER" ]; then
    echo "✓ PASS: Marker follows naming convention: $(basename $MARKER)"
else
    echo "✗ FAIL: No marker found or wrong naming"
    ls $MARKER_DIR
fi
kill $TEST_PID 2>/dev/null
wait $TEST_PID 2>/dev/null

# Final cleanup check
sleep 0.5
REMAINING=$(ls $MARKER_DIR 2>/dev/null | wc -l)
if [ "$REMAINING" -eq 0 ]; then
    echo "✓ PASS: All markers cleaned up"
else
    echo "✗ FAIL: $REMAINING markers still remain"
fi