# VisiData Usage Guide
- important things are marked with "(important!)"

## Basic Concepts
- **Sheet**: A table of data (like a spreadsheet tab)
- **Column**: Vertical data (fields)
- **Row**: Horizontal data (records)
- **Navigation**: All keyboard-driven (no mouse needed)

## Opening Files
```bash
vd filename.csv    # Open a CSV file
vd filename.json   # Open a JSON file
vd filename.xlsx   # Open an Excel file
```

## Basic Navigation
| Key | Action |
|-----|--------|
| `j` / `k` | Move down/up (like vim) |
| `h` / `l` | Move left/right between columns |
| `q` | Quit current sheet (or VisiData if on last sheet) |
| `Ctrl+H` | Open help menu |

## Column Operations

### Column Width & Display (important!)
| Key | Action |
|-----|--------|
| `_` | Adjust column width to fit visible data |
| `g_` | Adjust width for ALL columns |
| `-` | Hide current column |
| `gv` | Unhide all columns |
| `!` | Pin/unpin column (keeps it visible when scrolling) |

### Sorting (important!)
| Key | Action |
|-----|--------|
| `[` | Sort ascending by current column |
| `]` | Sort descending by current column |
| `g[` | Sort ascending by ALL key columns |
| `g]` | Sort descending by ALL key columns |
| `Ctrl+R` | Reload sheet (cancel sorting, restore original order) |

### Column Information
| Key | Action |
|-----|--------|
| `Shift+I` | Show column statistics |
| `Shift+C` | Open columns sheet (metadata about all columns) |

## Data Types

### Setting Column Types
| Key | Action |
|-----|--------|
| `#` | Set column type to integer |
| `%` | Set column type to float |
| `$` | Set column type to currency |
| `@` | Set column type to date |
| `~` | Set column type to text (string) |
| `z#` | Set column type to len (length/count) |

## Filtering and Searching

### Row Selection (important!)
| Key | Action |
|-----|--------|
| `s` | Select current row |
| `u` | Unselect current row |
| `gs` | Select all rows |
| `gu` | Unselect all rows |
| `t` | Toggle selection of current row |
| `gt` | Toggle selection of all rows |
| `"` | Open new sheet with only selected rows |
| `gz"` | Open new sheet with only NOT selected rows |

### Searching
| Key | Action |
|-----|--------|
| `/` | Search forward (regex) |
| `?` | Search backward (regex) |
| `n` | Next match |
| `N` | Previous match |
| `g/` | Search all columns |
| `c` | Search this column for cursor value |

### Filtering by Value (important!)
| Key | Action |
|-----|--------|
| `\|` | Select rows matching regex in current column |
| `\` | Unselect rows matching regex in current column |
| `,` | Select rows where current cell matches cursor value |
| `g,` | Select rows matching cursor row (all columns) |
