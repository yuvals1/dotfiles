# Before: Problems & Challenges

## Process Management Complexity

```
Issue: Multiple Processes Per Action
┌─────────────────────────────────────────────────────────┐
│  Single Radio Toggle Action:                           │
│                                                         │
│  Process 1: sketchybar → spotify_keyboard.sh          │
│  Process 2: spotify_keyboard.sh → spotify_cycle_radio.sh│
│  Process 3: spotify_cycle_radio.sh → spotify_command.sh │
│  Process 4: spotify_command.sh → spotify_player        │
│                                                         │
│  Result: 4 processes for 1 command!                    │
└─────────────────────────────────────────────────────────┘
```

## Race Conditions & State Sync Issues

| Problem | Impact | Example |
|---------|--------|---------|
| **File-based coordination** | Race conditions | Two scripts writing `.radio_state` simultaneously |
| **Process startup overhead** | Slow response | 200ms+ delay for simple commands |
| **Stale state files** | Inconsistency | UI shows radio mode, but API is in normal mode |
| **PID management** | Process leaks | Multiple `spotify_keyboard.sh` instances running |
| **Error propagation** | Silent failures | Child process fails, parent doesn't know |

## Debugging Nightmare

```
Problem Investigation Flow:
1. Check if sketchybar called the right script
2. Check if main script has correct PID management  
3. Check if state files have correct values
4. Check if child processes executed successfully
5. Check if spotify_player daemon is responsive
6. Check if UI polling detected the changes

6 layers to debug for a single button press!
```

⚡ **Root Cause**: Distributed state across processes and files creates coordination complexity