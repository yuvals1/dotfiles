# Design Patterns Applied

## Before: Distributed System Patterns

```
Command Pattern (Smart Wrapper):
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   UI Request    │───▶│ spotify_command │───▶│ spotify_player  │
│                 │    │ • Validation    │    │ • API execution │
│                 │    │ • Timeout       │    │                 │
│                 │    │ • Error handle  │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘

State Pattern (File-based):
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Radio State 0  │───▶│  Radio State 1  │───▶│  Radio State 2  │
│ (Normal Mode)   │    │ (Track Radio)   │    │ (Artist Radio)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         ▲                                             │
         └─────────┬─────────────────────────────────────┘
                   ▼
         ┌─────────────────┐
         │ .radio_state    │ ← File persistence
         │ .radio_seed     │
         └─────────────────┘
```

## After: Event Loop + State Machine Patterns

```
Event Loop Pattern:
┌─────────────────────────────────────────────────────────────────┐
│                        MAIN LOOP                               │
│                                                                 │
│  ┌───────────────┐  ┌──────────────┐  ┌─────────────────────┐  │
│  │ Command Phase │─▶│ Update Phase │─▶│   Sleep Phase       │  │
│  │ • Check queue │  │ • Get state  │  │ • 200ms fixed delay │  │
│  │ • Process cmd │  │ • Update UI  │  │ • Consistent timing │  │
│  └───────────────┘  └──────────────┘  └─────────────────────┘  │
│           ▲                                          │          │
│           └──────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────────┘

State Machine Pattern (In-Memory):
         Current State Variables
      ┌─────────────────────────┐
      │ radio_state: 0          │◀─┐
      │ radio_seed: ""          │  │ Direct
      │ is_force_repeat: false  │  │ memory
      │ current_track: "..."    │  │ access
      │ current_artist: "..."   │  │ (atomic)
      └─────────────────────────┘◀─┘

Command Queue Pattern:
External World           Daemon Process
┌─────────────┐          ┌─────────────┐
│echo "cmd" > │─────────▶│if [ -f cmd ]│
│/tmp/command │          │  process it │  
└─────────────┘          └─────────────┘
```

## Pattern Benefits Applied

| Pattern | Benefit Realized |
|---------|------------------|
| **Event Loop** | Predictable timing, centralized control |
| **State Machine** | Clear state transitions, no invalid states |
| **Command Queue** | Decoupled external interface |
| **Singleton Daemon** | Resource efficiency, state consistency |
| **Atomic Operations** | No race conditions, immediate consistency |

⚡ **Key Insight**: Right patterns for the problem domain matter more than following all patterns