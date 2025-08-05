# Before: Multi-Script Distributed System

## Complex Process Coordination Model

```
                    ┌─────────────────────────────────────────────┐
                    │              SKETCHYBAR UI                  │
                    │     (Event-driven script spawning)         │
                    └─────────┬───────────────────────────────────┘
                              │ UI Events
                              │ spawn scripts
                              ▼
            ┌─────────────────────────────────────────────────────────┐
            │                 SPOTIFY_KEYBOARD.SH                     │
            │              (Main Orchestrator)                        │
            │   • PID-based deduplication                            │
            │   • Smart caching layer                                │
            │   • Process coordination                               │
            └─────────────┬───────────────────────────────────────────┘
                          │ Spawns child processes
                          ▼
        ┌─────────────────────────┐         ┌─────────────────────────┐
        │   SPOTIFY_CYCLE_RADIO   │         │   SPOTIFY_COMMAND.SH   │
        │        (Radio)          │         │     (Wrapper)          │
        │ • File-based state      │◀────────┤ • Timeout handling     │
        │ • External state files  │         │ • Error management     │
        └─────────────┬───────────┘         └─────────┬───────────────┘
                      │                               │
                      ▼                               ▼
        ┌─────────────────────────┐         ┌─────────────────────────┐
        │  SPOTIFY_RADIO_STATE    │         │   SPOTIFY_PLAYER        │
        │     (State Mgmt)        │         │    (Rust Daemon)        │
        │ • ~/.config/.radio_state│         │ • Background process   │
        │ • ~/.config/.radio_seed │         │ • API communication    │
        └─────────────────────────┘         └─────────────────────────┘

                              │
                              │ File I/O for state
                              ▼
                    ┌─────────────────────────┐
                    │    FILESYSTEM STATE     │
                    │ • .spotify_radio_state  │
                    │ • .spotify_radio_seed   │
                    │ • .spotify_force_repeat │
                    │ • Multiple state files  │
                    └─────────────────────────┘
```

## Communication Patterns:
1. **UI → Main Script**: Event-based spawning
2. **Main → Children**: Process spawning with arguments  
3. **Scripts ↔ Files**: Read/write state coordination
4. **Scripts → Spotify**: API calls via rust daemon