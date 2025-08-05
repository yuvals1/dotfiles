# State Management: File-based vs In-Memory

## Before: Distributed File-based State

```
State Distribution Across Filesystem:
~/.config/sketchybar/
├── .spotify_radio_state     ← "1" (current mode)
├── .spotify_radio_seed      ← "Save That Shit" (track name)  
├── .spotify_force_repeat    ← "true" (repeat flag)
├── .spotify_radio_cycling   ← "1627834521" (timestamp)
└── .spotify_radio_starting  ← "starting" (loading flag)

State Access Pattern:
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Process A       │    │ Process B       │    │ Process C       │
│ read state=1    │    │ write state=2   │    │ read state=?    │
│ (stale data?)   │    │ (race cond?)    │    │ (inconsistent?) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 ▼
                    ┌─────────────────────────┐
                    │      FILESYSTEM         │
                    │ • No atomic updates     │
                    │ • Race conditions       │
                    │ • Stale reads possible  │
                    │ • Cleanup required      │
                    └─────────────────────────┘
```

## After: Unified In-Memory State

```
Single Process Memory Space:
┌─────────────────────────────────────────────────────────────────┐
│                    SPOTIFY.SH PROCESS                          │
│                                                                 │
│  State Variables (Direct Access):                              │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ radio_state=1              # Current radio mode        │   │
│  │ radio_seed="Save That Shit" # Track name for radio     │   │
│  │ is_force_repeat=false      # Force repeat flag         │   │
│  │ current_track="..."        # Latest track info         │   │
│  │ current_artist="..."       # Latest artist info        │   │
│  │ current_album="..."        # Latest album info         │   │
│  │ is_playing="true"          # Playback state            │   │
│  │ last_progress_ms=125000    # Progress tracking         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Single Thread Access:                                         │
│  • All reads/writes atomic                                     │
│  • No race conditions possible                                 │
│  • Always current data                                         │
│  • No cleanup required                                         │
└─────────────────────────────────────────────────────────────────┘
```

## State Update Comparison

| Operation | File-based (Before) | In-Memory (After) |
|-----------|-------------------|-------------------|
| **Read State** | `cat ~/.config/.radio_state` | `$radio_state` |
| **Write State** | `echo "1" > ~/.config/.radio_state` | `radio_state=1` |
| **Atomic Update** | ❌ Impossible (separate read/write) | ✅ Single instruction |
| **Consistency** | ❌ Files can be stale/corrupted | ✅ Always current |
| **Cleanup** | ❌ Manual file removal needed | ✅ Automatic (process exit) |
| **Performance** | ❌ Disk I/O overhead | ✅ Memory access speed |

## State Transition Example: Radio Toggle

```
File-based (Multiple I/O operations):
1. current=$(cat .radio_state)           # Disk read
2. next=$(( (current + 1) % 5 ))         # Calculation  
3. echo "$next" > .radio_state           # Disk write
4. echo "$track_name" > .radio_seed      # Disk write
5. rm .radio_cycling 2>/dev/null         # Disk cleanup

Race condition window: Steps 1-5 not atomic!

In-Memory (Single atomic operation):
1. radio_state=$(( (radio_state + 1) % 5 ))  # Memory update
2. radio_seed="$track_name"                   # Memory update

Atomic execution: Both updates in same process context!
```

⚡ **Result**: State operations went from 5 disk I/O ops to 2 memory assignments