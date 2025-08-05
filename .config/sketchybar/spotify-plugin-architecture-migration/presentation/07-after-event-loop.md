# After: Core Event Loop Pattern

## Game Loop / Tick-Based Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    MAIN EVENT LOOP                          │
│                   (5 FPS - 0.2s ticks)                     │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
            ┌─────────────────────┐
            │   Check Commands    │
            │                     │
            │ if [ -f $CMD_FILE ] │
            │   cmd=$(cat $CMD)   │
            │   rm $CMD_FILE      │
            │   handle_command    │
            │ fi                  │
            └─────────┬───────────┘
                      │
                      ▼
            ┌─────────────────────┐
            │  Update State & UI  │
            │                     │
            │ • Get playback JSON │
            │ • Parse track info  │
            │ • Update artwork    │
            │ • Update progress   │
            │ • Handle radio mode │
            │ • Check force-repeat│
            │ • Update context    │
            └─────────┬───────────┘
                      │
                      ▼
            ┌─────────────────────┐
            │    Sleep 0.2s       │
            │  (200ms = 5 FPS)    │
            └─────────┬───────────┘
                      │
                      └──────┐
                             │
                             ▼
                      ┌─────────────┐
                      │ Loop Again  │
                      └─────────────┘
```

## Command Processing Example:

```
Timeline: Radio Toggle Command Processing

T=0.0s    External: echo "radio_toggle" > /tmp/spotify_command
T=0.0s    Command file created
T=0.2s    Loop iteration: Detects command file
T=0.2s    Executes: handle_command "radio_toggle"
T=0.2s    Updates: radio_state=1, makes API call  
T=0.2s    Removes: command file
T=0.2s    Executes: update_state_and_ui()
T=0.2s    Updates: UI shows "Track Radio"
T=0.2s    Sleeps: 200ms
T=0.4s    Next iteration...

Total latency: 200ms maximum (deterministic)
```

⚡ **Key Benefits**: Predictable timing, atomic operations, centralized state