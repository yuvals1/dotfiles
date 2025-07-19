# Unused Keybinds

This document lists all keybinds that are currently unused in the dotfiles.

## Single Keys (Normal Mode)

| Key | Default Action | Alternative | Accessibility |
|-----|----------------|-------------|---------------|
| `s` | Substitute char | Use `cl` instead | Home row - Tier 1 |
| `S` | Substitute line | Use `cc` instead | Home row - Tier 1 |
| `K` | Man page lookup | Often remapped to LSP hover | Home row - Tier 1 |
| `;` | Repeat char search | Useful but often remapped | Home row - Tier 1 |
| `,` | Reverse char search | Rarely used after f/F/t/T | Tier 2 |
| `Q` | Ex mode | Almost never used | Tier 2 |
| `U` | Undo all on line | Rarely useful | Tier 2 |
| `Y` | Yank line | Use `yy` instead | Near home row |
| `T` | Till before char backward | Available | Near home row |
| `W` | Word forward (WORD) | Available | Near home row |
| `+` | First non-blank next line | Use `j^` instead | Tier 2 |
| `-` | First non-blank prev line | Use `k^` instead | Tier 2 |
| `&` | Repeat last `:s` | Rarely used | Tier 3 |
| `_` | First non-blank current | Use `^` instead | Tier 3 |
| `\` | Default leader | Rarely used as such | Tier 3 |
| `Z` | Only with ZZ/ZQ | Available | Tier 3 |
| `M` | Middle of screen | Less useful than H/L | Available |

## Control Key Combinations

### Currently Used in Config
| Key | Current Mapping |
|-----|-----------------|
| `<C-u>` | Previous diagnostic |
| `<C-d>` | Next diagnostic |
| `<C-g>` | Lazygit |

### Available Control Keys
| Key | Default Action | Notes |
|-----|----------------|-------|
| `<C-q>` | Terminal flow control | Usually available |
| `<C-s>` | Terminal flow control | Usually available |
| `<C-a>` | Insert prev text (insert mode) | Often remapped |
| Many `<C-[letter]>` | Various or unmapped | Check individually |

## Alt/Meta Combinations

| Pattern | Status | Common Usage |
|---------|--------|--------------|
| `<M-[letter]>` | Mostly unmapped | Available |
| `<M-h/j/k/l>` | Usually free | Window navigation |
| `<M-[number]>` | Usually free | Available |

## Function Keys

| Range | Status |
|-------|--------|
| `<F1>` - `<F12>` | Usually unmapped |
| `<S-F1>` - `<S-F12>` | Shifted - unmapped |
| `<F13>+` | Higher keys - unmapped |

## G-Prefix Combinations (Rarely Used)

| Combination | Default Action |
|-------------|----------------|
| `gQ` | Ex mode improved |
| `gR` | Virtual replace mode |
| `go` | Go to byte |
| `g&` | Repeat substitute with flags |
| `g@` | Call operatorfunc |
| `g#`, `g*` | Like #/* without boundaries |
| `g'`, `g`` | Jump to mark |

## Leader Key Patterns

| Pattern | Common Usage |
|---------|--------------|
| `<leader>[a-z]` | Single letter commands |
| `<leader>[a-z][a-z]` | Double letter commands |
| `<leader>f` | File operations |
| `<leader>g` | Git operations |
| `<leader>b` | Buffer operations |
| `<leader>w` | Window operations |
| `<leader>t` | Tab/test operations |

## Visual Mode Specific

The following keys have the same availability in visual mode as normal mode:
- `Q`, `K`, `&`, and many `g` combinations

## Common Remapping Patterns

| Use Case | Common Keys |
|----------|-------------|
| Window Navigation | `<C-h/j/k/l>` |
| Quick Actions | `s` for surround/substitute plugins |
| Search Enhancement | `;` and `,` for next/prev |
| LSP Actions | `K` for hover, `gd` for definition |
| Diagnostics | `[d` and `]d` or custom |

## Notes

- Keys like `<C-c>` and `<C-[>` should generally not be remapped
- Terminal emulators may intercept some combinations
- Check plugin documentation as they may use "unused" keys
- Consider mode-specific mappings to maximize available keys