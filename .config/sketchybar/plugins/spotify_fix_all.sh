#!/bin/bash

# Comprehensive Spotify troubleshooting script
# Fixes both API connection issues and UI display problems

echo "🔧 Running complete Spotify fix..."
echo ""

# Step 1: Kill all existing processes
echo "1️⃣ Stopping all Spotify processes..."
pkill -f "spotify.sh" 2>/dev/null
pkill -f "spotify_player --daemon" 2>/dev/null
sleep 2

# Step 2: Clean up stale files
echo "2️⃣ Cleaning up temporary files..."
rm -f /tmp/spotify_command
rm -f /tmp/spotify_daemon.pid
rm -f /tmp/spotify_cover.jpg

# Step 3: Start Spotify API daemon
echo "3️⃣ Starting Spotify API daemon..."
/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player --daemon &
sleep 3

# Step 4: Verify device is registered
echo "4️⃣ Verifying Spotify device registration..."
devices=$(/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player get key devices 2>/dev/null)
if [ "$devices" = "[]" ] || [ -z "$devices" ]; then
    echo "   ⚠️  No devices found. Retrying..."
    sleep 3
    devices=$(/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player get key devices 2>/dev/null)
fi

if [ "$devices" != "[]" ] && [ -n "$devices" ]; then
    echo "   ✅ Device registered successfully"
else
    echo "   ❌ Device registration failed. You may need to re-authenticate."
fi

# Step 5: Start UI daemon
echo "5️⃣ Starting UI daemon..."
nohup /Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/spotify.sh > /tmp/spotify.log 2>&1 &
sleep 2

# Step 6: Reset view state to Spotify
echo "6️⃣ Resetting to Spotify view..."
echo "0" > $HOME/.config/sketchybar/.center_state
/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/toggle_center_view.sh >/dev/null 2>&1
/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/toggle_center_view.sh >/dev/null 2>&1
/Users/yuvalspiegel/dotfiles/.config/sketchybar/plugins/toggle_center_view.sh >/dev/null 2>&1

# Step 7: Test playback
echo "7️⃣ Testing Spotify connection..."
playback=$(/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player get key playback 2>/dev/null | jq -r '.is_playing // "error"')
if [ "$playback" != "error" ]; then
    echo "   ✅ Spotify API connection working"
    echo "   📊 Playback status: $playback"
else
    echo "   ❌ Spotify API connection failed"
fi

echo ""
echo "✨ Spotify fix complete!"
echo ""
echo "If issues persist:"
echo "  - Check your internet connection"
echo "  - Try playing something in the Spotify app"
echo "  - Run 'spotify_player' to re-authenticate if needed"