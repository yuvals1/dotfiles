#!/bin/bash

echo "=== Spotify Wrapper Stress Test ==="
echo "This will simulate heavy concurrent usage"
echo

# Function to run random commands
run_random_command() {
    local source=$1
    local commands=("playback play-pause" "playback next" "playback previous" "get key playback")
    local cmd=${commands[$RANDOM % ${#commands[@]}]}
    
    SPOTIFY_SOURCE=$source /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh $cmd >/dev/null 2>&1
}

echo "Test 1: 100 concurrent commands from different sources"
echo "Starting..."
START_TIME=$(date +%s)

for i in {1..25}; do
    run_random_command "keyboard" &
    run_random_command "display" &
    run_random_command "radio" &
    run_random_command "event" &
done

wait
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "Completed in ${DURATION}s"
echo

echo "Test 2: Rapid display updates (simulating 10 second polling)"
echo "Starting 10 second rapid poll..."
for i in {1..10}; do
    SPOTIFY_SOURCE=display /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_command.sh get key playback >/dev/null 2>&1 &
    sleep 1
done
wait
echo "Done"
echo

echo "Test 3: User mashing Alt+I (50 rapid play/pause)"
echo "Starting..."
START_TIME=$(date +%s.%N)
for i in {1..50}; do
    /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify_keyboard.sh play-pause &
done
wait
END_TIME=$(date +%s.%N)
DURATION=$(echo "$END_TIME - $START_TIME" | bc)

echo "Completed 50 play/pause in ${DURATION}s"
echo "Average per command: $(echo "scale=3; $DURATION / 50" | bc)s"
echo

echo "Final check: Hanging processes"
HANGING=$(pgrep -f "spotify_player.*get\|playback\|play\|search" | wc -l)
echo "Hanging processes: $HANGING (should be 0)"

echo
echo "Marker files check:"
MARKERS=$(ls /Users/yuvalspiegel/.config/sketchybar/.spotify_markers 2>/dev/null | wc -l)
echo "Remaining markers: $MARKERS (should be 0)"

if [ "$HANGING" -eq 0 ] && [ "$MARKERS" -eq 0 ]; then
    echo
    echo "✓ STRESS TEST PASSED"
else
    echo
    echo "✗ STRESS TEST FAILED"
    if [ "$HANGING" -gt 0 ]; then
        echo "Hanging processes:"
        ps aux | grep spotify_player | grep -E "get|playback|play|search" | grep -v grep
    fi
    if [ "$MARKERS" -gt 0 ]; then
        echo "Remaining markers:"
        ls /Users/yuvalspiegel/.config/sketchybar/.spotify_markers
    fi
fi