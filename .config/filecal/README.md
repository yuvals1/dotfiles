# Filecal Daemon

A file-based calendar system where folders are dates and files are events, with automatic macOS tagging for visual indicators and multiple view modes via symlinks.

## Installation

```bash
./install.sh      # Install and start daemon
./uninstall.sh    # Stop and remove daemon
./daemon.sh update # Run manual update once (for testing)
```

## Directory Structure

```
~/personal/calendar/
├── days/                    # Main calendar folders (one per day)
│   ├── 2025-08-14  (4)/    # Tagged: Point (today)
│   │   ├── 0900-meeting    # Event files
│   │   └── 1400-lunch
│   ├── 2025-08-15  (5)/    # Tagged: Red (has urgent events)
│   │   └── 1800-deadline   # Contains "category:Red"
│   ├── 2025-08-16  (6)/    # Tagged: Green (has events)
│   │   └── 1000-standup
│   └── 2025-08-17  (7)/    # No tag (empty)
├── list-view/               # Flat view of ALL events (symlinks)
│   ├── 2025-08-14-0900-meeting
│   ├── 2025-08-14-1400-lunch
│   ├── 2025-08-15-1800-deadline
│   └── 2025-08-16-1000-standup
└── month-view/              # Current month's events only (symlinks)
    ├── 14-0900-meeting
    ├── 14-1400-lunch
    ├── 15-1800-deadline
    └── 16-1000-standup
```

## Daemon Logic

Runs every 10 minutes, executing five tasks:

### 1. Tag Today (`tag_today`)
- Remove "Point" tag from yesterday
- Add "Point" tag to today's folder
- Today always shows 👉 in Finder/yazi

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

### 4. Sync List View (`sync_list_view`)
- Rebuilds `list-view/` directory with symlinks to ALL events
- Format: `YYYY-MM-DD-eventname` (e.g., `2025-08-15-0900-meeting`)
- Provides flat, chronologically sortable view of entire calendar

### 5. Sync Month View (`sync_month_view`)
- Rebuilds `month-view/` directory with symlinks to current month only
- Format: `DD-eventname` (e.g., `15-0900-meeting`)
- Automatically switches to new month at month boundaries
- Provides focused view of current month's events

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

1. **Point** - Today only (overrides all)
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