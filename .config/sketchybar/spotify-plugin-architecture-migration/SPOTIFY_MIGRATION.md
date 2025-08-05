# Spotify Plugin Architecture Migration

## **Before: Multi-Script Distributed System**

### Architecture
- **Multiple specialized scripts**: Each handling specific functionality
- **File-based state management**: External files for coordination
- **Event-driven triggers**: Sketchybar events spawning individual scripts
- **Process coordination**: Complex PID management and file semaphores

### Key Components
```
spotify_keyboard.sh          # Main orchestrator
spotify_command.sh           # Smart wrapper with caching
spotify_player daemon        # Background Rust process
spotify_cycle_radio.sh       # Radio mode cycling
spotify_radio_state.sh       # File-based state management
Multiple trigger scripts     # Individual UI updates
```

### Problems
- **Process management complexity**: Multiple scripts spawning processes
- **State synchronization**: File-based coordination prone to race conditions  
- **Performance overhead**: Spawning new processes for every interaction
- **Debugging difficulty**: Distributed logic across many files

## **After: Unified State Machine**

### Architecture
- **Single infinite loop**: One process handling everything
- **In-memory state**: No external state files needed
- **Event loop pattern**: 5 FPS tick rate (0.2s intervals)
- **Command queue**: File-based communication for external commands

### Core Pattern
```bash
while true; do
  # Handle external commands (if any)
  if [ -f "$COMMAND_FILE" ]; then
    command=$(cat "$COMMAND_FILE")
    rm "$COMMAND_FILE"
    handle_command "$command"
  fi
  
  # Tick: Update state and UI every iteration
  update_state_and_ui
  
  sleep 0.2
done
```

## **Migration Steps**

### 1. **Analysis Phase**
- Read and understood complex multi-script architecture
- Identified patterns: Command Pattern, Process Coordination, Event-Driven Architecture
- Mapped all UI components and their relationships

### 2. **Preservation Strategy**
- Kept UI configuration unchanged in `items/spotify.sh`
- Moved old scripts to `old_plugins/` directory
- Maintained existing keyboard shortcuts and integrations

### 3. **Implementation Phase**
```bash
# New unified structure
spotify.sh              # Single state machine (replaces 6+ scripts)
spotify_command.sh       # External command interface
Hammerspoon integration  # Updated to use new interface
```

### 4. **Feature Parity**
- ✅ Basic controls (play/pause, next/previous)
- ✅ Album artwork with real-time downloading
- ✅ Progress bar with time display
- ✅ Context display (playlist/album/artist names)
- ✅ Force-repeat functionality (in-memory, no files)
- ✅ 4-state radio cycling with real API calls
- ✅ Seek commands (+/-10 seconds)

### 5. **Integration Issues & Solutions**
- **Multiple processes**: Fixed by removing `script=` from UI items
- **Stale daemon data**: Created manual restart mechanism
- **UI flickering**: Added PID file management
- **View state conflicts**: Added center state checking

## **Key Technical Improvements**

### State Management
```bash
# Before: File-based
echo "1" > ~/.config/sketchybar/.spotify_radio_state
state=$(cat ~/.config/sketchybar/.spotify_radio_state)

# After: In-memory variables
radio_state=1  # Direct variable access
```

### Process Architecture
```bash
# Before: Multiple processes
spotify_keyboard.sh → spawns → spotify_cycle_radio.sh → spawns → spotify_command.sh

# After: Single process with command queue
echo "radio_toggle" > /tmp/spotify_command  # External interface
# Daemon picks up and processes internally
```

### API Integration
```bash
# Before: UI-only mockups
sketchybar --set spotify.context label="Track Radio"

# After: Real Spotify API calls
$SPOTIFY playback start radio --id "$track_id" track
```

## **Architecture Benefits**

### Performance
- **Reduced CPU usage**: Single process vs multiple spawning processes
- **Lower memory footprint**: One daemon vs multiple concurrent scripts
- **Faster response**: No process startup overhead

### Reliability
- **Atomic state**: All state in single process memory
- **No race conditions**: Sequential command processing
- **Better error handling**: Centralized error management
- **Automatic recovery**: Daemon restart capability

### Maintainability
- **Single source of truth**: All logic in one file
- **Easier debugging**: Centralized logging
- **Simpler deployment**: One daemon to manage
- **Clear interfaces**: Command-based external API

## **Final System Integration**

### Keyboard Shortcuts (Hammerspoon)
```lua
Alt+Space → play-pause
Alt+N     → next
Alt+B     → previous  
Alt+S     → shuffle
Alt+P     → repeat (force-repeat)
Alt+R     → radio_toggle
Alt+Cmd+U → seek-backward
Alt+Cmd+O → seek-forward
```

### View State Management
- **State 0**: Spotify view (daemon active)
- **State 1**: YouTube view (daemon paused)
- **State 2**: Pomodoro view (daemon paused)

### Command Interface
```bash
spotify_command.sh radio_toggle    # External commands
echo "play-pause" > /tmp/spotify_command  # Direct queue
```

The migration transformed a complex distributed system into a clean, maintainable state machine while preserving all functionality and improving performance.