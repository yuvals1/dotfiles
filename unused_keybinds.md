# Unused Keybinds

This document lists all keybinds that are currently unused in the dotfiles.

## Most Valuable Single Keys (Normal Mode)

### Home Row & Easy Access
- `s` - Substitute char (default action can use `cl` instead)
- `S` - Substitute line (unneeded because `cc` has the same functionality)
- `K` - Man page lookup (commonly remapped to LSP hover)
- `;` - Repeat character search (useful but often remapped)
- `,` - Reverse character search (rarely used after f/F/t/T)

### Near Home Row
- `Q` - Ex mode (almost never used)
- `U` - Undo all changes on line (rarely useful)
- `Y` - Yank line (unneeded because `yy` has the same functionality)
- `T` - Till before character backward
- `W` - Word forward (WORD)
- `+` - Move to first non-blank of next line (redundant with `j^`)
- `-` - Move to first non-blank of previous line (redundant with `k^`)

### Less Accessible But Available
- `&` - Repeat last substitute (`:s`) command
- `_` - Move to first non-blank of current line (redundant with `^`)
- `\` - Default leader key (but rarely used as such)
- `Z` - Only used with ZZ/ZQ combinations
- `M` - Move to middle of screen (less useful than H/L)

## Control Key Combinations

### Currently Used
- ~`<C-u>`~ - used for prev diagnostic
- ~`<C-d>`~ - used for next diagnostic
- ~`<C-g>`~ - used for lazygit

### Commonly Available
- `<C-q>` - Usually available (terminal flow control)
- `<C-s>` - Usually available (terminal flow control)
- Many other `<C-[letter]>` combinations in normal mode

### Insert Mode Control Keys
- `<C-a>` - Insert previously inserted text (often remapped)
- `<C-g>` + combinations - Many unmapped

## Alt/Meta Combinations
- Most `<M-[key]>` combinations are unmapped
- `<M-h>`, `<M-j>`, `<M-k>`, `<M-l>` - Popular for window navigation
- `<M-[number]>` - Usually free
- `<M-[letter]>` - Most letters available

## Function Keys
- `<F1>` through `<F12>` - Usually unmapped
- `<S-F1>` through `<S-F12>` - Shifted function keys
- `<F13>` and beyond - Higher function keys

## G-Prefix Combinations (Rarely Used)
- `gQ` - Enter Ex mode with improved behavior
- `gR` - Virtual replace mode
- `go` - Go to byte in file
- `g&` - Repeat last substitute with flags
- `g@` - Call operatorfunc
- `g#` / `g*` - Like # and * but without word boundaries
- `g'` / `g`  - Jump to mark without/with column

## Leader Key Combinations
If using a custom leader (like space):
- Single letters: `<leader>a` through `<leader>z`
- Double letters: `<leader>aa`, `<leader>bb`, etc.
- Common patterns: 
  - `<leader>f` (files)
  - `<leader>g` (git)
  - `<leader>b` (buffers)
  - `<leader>w` (windows)
  - `<leader>t` (tabs/tests)

## Visual Mode Specific
- `Q` - Same as normal mode
- `K` - Same as normal mode
- `&` - Same as normal mode
- Many `g` combinations

## Remapping Tiers by Accessibility

### Tier 1 (Most Accessible - Home Row)
- `s` - Very easy to reach, commonly remapped
- `;` - Pinky position, easy to reach
- `K` - Right hand home row

### Tier 2 (Very Accessible)
- `Q` - Close to home row
- `U` - Close to common keys
- `,` - Easy to reach
- `-` and `+` - Right hand accessible

### Tier 3 (Moderate Access)
- `\` - Default leader, bit of a reach
- `&` - Requires shift
- `_` - Requires shift
- `Z` - Corner key

## Common Remapping Patterns

1. **Window Navigation:** `<C-h/j/k/l>`
2. **Quick Actions:** `s` for substitute/surround plugins
3. **Search Enhancement:** `;` and `,` for next/previous occurrence
4. **Leader Combinations:** `<leader>` + letter for plugin commands
5. **LSP Actions:** `K` for hover, `gd` for go to definition
6. **Diagnostic Navigation:** `[d` and `]d` or custom mappings

## Notes
- Some keys like `<C-c>` and `<C-[>` should generally not be remapped
- Terminal emulators may intercept some key combinations
- Some plugins may use these "unused" keys, so check plugin documentation
- Consider mode-specific mappings to maximize available keys
