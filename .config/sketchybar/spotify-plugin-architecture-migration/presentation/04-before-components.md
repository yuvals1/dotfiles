# Before: Component Breakdown

## Six Specialized Scripts + External State

| Component | Purpose | State Management | Process Model |
|-----------|---------|------------------|--------------| 
| **spotify_keyboard.sh** | Main orchestrator | PID files, caching | Spawns children |
| **spotify_command.sh** | Smart wrapper | Timeout handling | Single execution |
| **spotify_cycle_radio.sh** | Radio mode cycling | External files | Event-triggered |  
| **spotify_radio_state.sh** | State functions | File read/write | Library functions |
| **Multiple UI scripts** | Individual updates | None | Event-spawned |
| **spotify_player daemon** | Rust API backend | Internal | Background process |

## External State Files (Filesystem Coordination):
```
~/.config/sketchybar/
├── .spotify_radio_state     ← Current radio mode (0-4)
├── .spotify_radio_seed      ← Track/artist/album name  
├── .spotify_force_repeat    ← Force-repeat flag
├── .spotify_radio_cycling   ← Cycling state flag
└── .spotify_radio_starting  ← Loading state flag
```

## Process Lifecycle Example:
1. **UI Event**: User presses Alt+R
2. **Sketchybar**: Spawns `spotify_keyboard.sh radio_toggle`
3. **Main Script**: Checks PID, spawns `spotify_cycle_radio.sh`
4. **Radio Script**: Reads state file, calculates next state, spawns API call
5. **API Script**: Executes spotify_player command, updates state files
6. **UI Update**: Triggered by file changes or polling

⚡ **Problem**: 6 processes + 5 state files for single radio toggle!