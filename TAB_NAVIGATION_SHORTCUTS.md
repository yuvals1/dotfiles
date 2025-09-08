# Tab Navigation Shortcuts Configuration

## Current Setup
You currently have 3 different tab navigation shortcut sets configured for Chrome:

1. **Vim-style**: `Cmd+Shift+L` (next) / `Cmd+Shift+H` (previous)
2. **Bracket-style**: `Cmd+]` (next) / `Cmd+[` (previous) 
3. **M/Period-style**: `Cmd+.` (next) / `Cmd+M` (previous)

## Configuration Locations

### Chrome Tab Switching (Karabiner)
**File**: `.config/karabiner/assets/complex_modifications/chrome-mappings.json`

- Lines 99-119: Vim-style L mapping (Cmd+Shift+L → next tab)
- Lines 121-141: Vim-style H mapping (Cmd+Shift+H → previous tab)
- Lines 55-75: Bracket ] mapping (Cmd+] → next tab)
- Lines 77-97: Bracket [ mapping (Cmd+[ → previous tab)
- Lines 143-163: Period mapping (Cmd+. → next tab)
- Lines 165-185: M mapping (Cmd+M → previous tab)

### Tmux Window Switching (Kitty)
**File**: `.config/kitty/kitty.conf`

- Lines 104-105: M/Period mappings only
  - `map cmd+m send_text all \x02p` (previous window)
  - `map cmd+. send_text all \x02n` (next window)

## To Remove Unwanted Shortcuts

Tell Claude which style you want to keep:
- "Keep only vim-style (Cmd+Shift+L/H)"
- "Keep only bracket-style (Cmd+]/[)"
- "Keep only M/period-style (Cmd+./M)"

Claude will then remove the other two sets from the chrome-mappings.json file.