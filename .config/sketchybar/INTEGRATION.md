# SketchyBar Integration Guide

## Overview
This SketchyBar configuration integrates with several external tools to provide a rich status bar experience.

## External Dependencies

### 1. **spotify_player** (Spotify Control)
- **Location**: `/Users/yuvalspiegel/dev/spotify-player/target/release/spotify_player`
- **Build**: `cargo build --release --no-default-features --features daemon,image,notify,rodio-backend`
- **Usage**: Runs as daemon (`spotify_player --daemon`) for instant command execution
- **Features**:
  - Playback control (play/pause, next, previous)
  - Metadata queries (current track, playback state)
  - Shuffle/repeat toggles
  - Event hooks for real-time updates

### 2. **YouTube Music Desktop App**
- **Install**: `brew install th-ch/youtube-music/youtube-music`
- **API Server**: Enable in app settings (Plugins → API Server)
- **Port**: 26538
- **Features**:
  - REST API for playback control
  - Song metadata and progress
  - No shuffle/repeat state in API

### 3. **Hammerspoon** (Keyboard Shortcuts)
- **Config**: `~/.hammerspoon/init.lua`
- **Music Shortcuts**:
  - Alt+Y: Shuffle
  - Alt+U: Previous track
  - Alt+I: Play/Pause
  - Alt+O: Next track
  - Alt+P: Repeat
  - Alt+R: Toggle center view (Pomodoro/Spotify/YouTube Music)

### 4. **aerospace** (Window Management)
- **Purpose**: Workspace management and window information
- **Integration**: Shows current workspace and window count

### 5. **input_source_monitor.swift** (Language Switching)
- **Location**: `~/.config/sketchybar/helpers/input_source_monitor.swift`
- **Purpose**: Monitors keyboard input source changes

## Plugin Architecture

### Music Services
- **Dispatcher**: `music_keyboard_dispatcher.sh` routes commands based on visible service
- **State Management**: `.center_state` file tracks current view (0=Spotify, 1=YouTube Music, 2=Pomodoro)
- **Display Scripts**: 
  - `spotify_display.sh`: Updates via daemon queries and event hooks
  - `youtube_music_display.sh`: Polls API for updates

### Event System
- **Spotify**: Uses `player_event_hook_command` for real-time updates
- **YouTube Music**: Polling-based (1s playing, 5s paused)
- **Custom Events**: `spotify_update`, `youtube_music_update`

### Smart Features
- **Adaptive Polling**: Adjusts frequency based on playback state
- **Auto-play on Next**: Ensures music continues after track skip
- **Artwork Caching**: Downloads album art to `/tmp/`

## Configuration Files

### Key Files
- `sketchybarrc`: Main configuration, loads all items
- `items/spotify.sh`: Spotify UI components
- `items/youtube_music.sh`: YouTube Music UI components
- `plugins/toggle_center_view.sh`: View switching logic
- `plugins/init_center_view.sh`: Initial state setup

### State Persistence
- `.center_state`: Current center view (survives restarts)
- Daemon processes: Started by sketchybar on launch

## Troubleshooting

### Spotify Not Working
1. Check daemon: `ps aux | grep spotify_player`
2. Start manually: `spotify_player --daemon &`
3. Verify build features include `daemon`

### YouTube Music Not Working
1. Check API server enabled in app
2. Test API: `curl http://localhost:26538/api/v1/song-info`
3. Disable authentication in plugin settings

### Keyboard Shortcuts Not Working
1. Reload Hammerspoon config
2. Check `.center_state` for current view
3. Verify dispatcher script permissions