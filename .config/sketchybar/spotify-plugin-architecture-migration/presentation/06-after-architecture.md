# After: Unified State Machine Architecture

## Single Process with Command Queue Interface

```
                    ┌─────────────────────────────────────────────┐
                    │              SKETCHYBAR UI                  │
                    │         (No script spawning)               │
                    └─────────────────────────────────────────────┘
                                          ▲
                                          │ UI Updates
                                          │ (drawing=on/off)
                                          │
                    ┌─────────────────────────────────────────────┐
                    │             SPOTIFY.SH DAEMON               │
                    │         (Single Infinite Loop)              │
                    │                                             │
                    │  ┌─────────────────────────────────────┐    │
                    │  │        MAIN EVENT LOOP              │    │
                    │  │                                     │    │
                    │  │  while true; do                     │    │
                    │  │    # Handle commands                │    │
                    │  │    if [ -f $COMMAND_FILE ]; then    │    │
                    │  │      handle_command                 │    │
                    │  │    fi                               │    │
                    │  │                                     │    │
                    │  │    # Update UI (5 FPS)              │    │
                    │  │    update_state_and_ui              │    │
                    │  │                                     │    │
                    │  │    sleep 0.2                        │    │
                    │  │  done                               │    │
                    │  └─────────────────────────────────────┘    │
                    │                                             │
                    │  In-Memory State Variables:                 │
                    │  • radio_state=0                           │
                    │  • radio_seed=""                           │
                    │  • is_force_repeat=false                   │
                    │  • current_track, current_artist, etc.     │
                    └─────────────┬───────────────────────────────┘
                                  │
                                  │ API Calls
                                  ▼
                    ┌─────────────────────────────────────────────┐
                    │           SPOTIFY_PLAYER                    │
                    │          (Rust Daemon)                      │
                    │ • Single background process                 │
                    │ • API communication                         │
                    └─────────────────────────────────────────────┘

External Interface:                    Command Queue:
┌─────────────────────┐               ┌─────────────────────┐
│ SPOTIFY_COMMAND.SH  │──────────────►│ /tmp/spotify_command│
│ • Input validation  │               │ • File-based queue  │
│ • Command dispatch  │               │ • Single command    │
└─────────────────────┘               └─────────────────────┘
```

## Key Architectural Changes:
1. **1 Process** instead of 6+ processes
2. **In-Memory State** instead of 5 filesystem files  
3. **Event Loop** instead of event-driven spawning
4. **Command Queue** instead of process hierarchies