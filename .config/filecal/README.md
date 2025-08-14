# Filecal Daemon

A file-based calendar system where folders are dates and files are events, with automatic macOS tagging for visual indicators in file managers.

## Installation

```bash
./install.sh    # Install and start daemon
./uninstall.sh  # Stop and remove daemon
```

## Directory Structure

```
~/personal/calendar/days/
├── 2025-08-14/          # Tagged: Important (today)
│   ├── 0900-meeting     # Event files
│   └── 1400-lunch
├── 2025-08-15/          # Tagged: Red (has urgent events)
│   └── 1800-deadline    # Contains "category:Red"
├── 2025-08-16/          # Tagged: Green (has events)
│   └── 1000-standup
└── 2025-08-17/          # No tag (empty)
```

## Daemon Logic

Runs every 10 minutes, executing three tasks:

### 1. Tag Today (`tag_today`)
- Remove "Important" tag from yesterday
- Add "Important" tag to today's folder
- Today always shows ❗ in Finder/yazi

### 2. Create Future Folders (`create_future_folders`)
- Maintains 60 days of empty folders ahead
- Enables future planning without manual folder creation

### 3. Tag by Content (`tag_all_days`)
For each day folder (except today):

| Folder State | Tag Applied | Visual |
|-------------|------------|--------|
| Has event with `category:Red` | Red | 🔴 |
| Has any events | Green | 🟢 |
| Empty folder | None | - |

### Tag Transitions
- **Add event** → Empty becomes Green
- **Add `category:Red`** → Green becomes Red  
- **Remove `category:Red`** → Red becomes Green
- **Delete all events** → Any tag cleared

## Event Format

```
# File: days/2025-08-15/1800-deadline
category:Red
description:Project deadline
```

## Tag Hierarchy

1. **Important** - Today only (overrides all)
2. **Red** - Urgent/important events
3. **Green** - Regular events  
4. **None** - Empty days

## Logs

- Output: `/tmp/filecal-daemon.log`
- Errors: `/tmp/filecal-daemon.err`

## Configuration

Edit `com.filecal.daemon.plist` to change:
- `CALENDAR_DIR` - Calendar location (default: `~/personal/calendar`)
- Update interval - Currently 600 seconds (10 minutes)