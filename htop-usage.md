# htop Usage Guide

## Basic Launch
```bash
htop
```

## Understanding the Display

### Top Section (System Overview)
- **CPU bars**: One per core, colors show: blue=low priority, green=normal, red=kernel
- **Mem**: Physical RAM usage (green=used, blue=buffers, yellow=cache)
- **Swp**: Swap space usage
- **Tasks, thr, kthr**: Process/thread counts
- **Load average**: 1, 5, and 15-minute averages
- **Uptime**: How long system has been running

### Bottom Section (Process List)
- **PID**: Process ID
- **USER**: Process owner
- **PRI/NI**: Priority/Nice value
- **VIRT/RES/SHR**: Virtual/Resident/Shared memory
- **S**: State (R=running, S=sleeping, Z=zombie)
- **CPU%**: CPU usage
- **MEM%**: Memory usage
- **TIME+**: Total CPU time
- **Command**: Process name/command

## Essential Keys

### Navigation
- `↑/↓`: Move through process list
- `PgUp/PgDn`: Page up/down
- `Home/End`: Jump to top/bottom

### Viewing
- `H`: **Toggle threads** (show/hide individual threads)
- `K`: Toggle kernel threads
- `t`: Toggle tree view (show parent-child relationships)
- `F5`: Tree view (same as `t`)
- `F2`: Setup menu (detailed configuration)

### Sorting
- `F6` or `>`: Choose sort column
- `P`: Sort by CPU%
- `M`: Sort by MEM%
- `T`: Sort by TIME
- `Shift+P/M/T`: Reverse sort

### Process Management
- `F9` or `k`: Kill process (sends signal)
  - Choose signal: `15=SIGTERM` (graceful), `9=SIGKILL` (force)
- `Space`: Tag/untag process (to operate on multiple)
- `U`: Filter by user
- `F3` or `/`: Search for process
- `F4` or `\`: Filter (only show matching)
- `c`: Tag and show full command line

### Display Options
- `F2`: Enter setup
  - "Display options" → Toggle various settings
  - **"Show custom thread names"** ← Enable this for thread names!
  - "Hide kernel threads"
  - "Tree view"
  - "Show program path"
- `u`: Show processes for specific user
- `F10` or `q`: Quit

## Common Workflows

### 1. Find CPU-hungry process
1. Press `P` (sort by CPU)
2. Look at top of list
3. Press `k` to kill if needed

### 2. View threads of a specific process
1. Press `H` (show threads)
2. Press `t` (tree view) - threads appear under parent
3. `F2` → Display options → Enable "Show custom thread names"

### 3. Find memory leak
1. Press `M` (sort by memory)
2. Watch RES column over time
3. Look for growing processes

### 4. Kill multiple processes
1. Navigate to process
2. Press `Space` (tag it)
3. Repeat for other processes
4. Press `F9` to kill all tagged

### 5. Monitor specific application
1. Press `F4` (filter)
2. Type process name (e.g., "firefox")
3. Only matching processes shown
4. `ESC` to clear filter

## Pro Tips

1. **Color meanings**: Press `F1` for help, explains all colors
2. **Nice value**: Lower = higher priority (-20 to 19)
3. **Load average**: Should be < number of CPU cores for healthy system
4. **Memory colors**: Green (used) + yellow (cache) is normal; cache is freed when needed
5. **Zombie processes**: If you see many `Z` states, parent isn't cleaning up children
6. **Save settings**: Changes in F2 menu are saved to `~/.config/htop/htoprc`

## Quick Reference Card
```
F1  Help           F6  Sort by       Space Tag process
F2  Setup          F9  Kill          H     Toggle threads
F3  Search         F10 Quit          K     Kernel threads
F4  Filter         P   Sort CPU%     t     Tree view
F5  Tree           M   Sort MEM%     u     Filter user
```

## Advanced Features

### CPU Affinity
- Select a process
- Press `a` to set CPU affinity (which cores process can use)
- Useful for pinning processes to specific cores

### Process Priority (Renice)
- Select a process
- Press `F7` to decrease priority (increase nice value)
- Press `F8` to increase priority (decrease nice value)
- Requires root for negative nice values

### Following Process
- Press `F` to follow a process (keeps it visible even if it moves in sort order)

### Strace Integration
- Select a process
- Press `s` to strace the process (if strace is installed)
- Shows system calls in real-time

## Configuration File

htop saves settings to `~/.config/htop/htoprc`

Key settings you might want to customize:
- `show_thread_names=1` - Show custom thread names
- `show_program_path=1` - Show full path in command
- `tree_view=1` - Start in tree view
- `hide_kernel_threads=1` - Hide kernel threads by default
- `hide_userland_threads=0` - Show userland threads
- `highlight_base_name=1` - Highlight process basename
- `highlight_threads=1` - Highlight threads in different color

## Memory Types Explained

- **VIRT**: Virtual memory size (total memory allocated, including swapped)
- **RES**: Resident memory (physical RAM actually used)
- **SHR**: Shared memory (memory shared with other processes)
- **MEM%**: Percentage of physical RAM used

The important one is **RES** - that's actual RAM usage.

## Process States

- **R**: Running or runnable (on run queue)
- **S**: Sleeping (waiting for an event to complete)
- **D**: Uninterruptible sleep (usually I/O)
- **Z**: Zombie (terminated but not reaped by parent)
- **T**: Stopped (by job control signal)
- **t**: Stopped by debugger during tracing
- **W**: Paging (not valid on Linux 2.6+)
- **X**: Dead (should never be seen)
- **<**: High priority (not nice to other processes)
- **N**: Low priority (nice to other processes)
- **L**: Has pages locked into memory (for real-time and custom I/O)
- **s**: Session leader
- **l**: Multi-threaded
- **+**: In foreground process group

## Signals Reference

Common signals to send with `F9`:
- **1 (HUP)**: Hangup - often causes reload of config
- **2 (INT)**: Interrupt - same as Ctrl+C
- **3 (QUIT)**: Quit and dump core
- **9 (KILL)**: Force kill immediately (can't be caught)
- **15 (TERM)**: Terminate gracefully (default, preferred)
- **18 (CONT)**: Continue if stopped
- **19 (STOP)**: Stop/pause process
- **20 (TSTP)**: Stop typed at terminal (Ctrl+Z)

Always try **15 (TERM)** first, use **9 (KILL)** only as last resort.
