# macOS Tags in Yazi — Quick Guide

This setup makes macOS tags a first‑class experience in Yazi using core support, theme rules, and a minimal plugin for actions.

- Core
  - Tags are read directly from xattr (com.apple.metadata:_kMDItemUserTags) — no plugin fetchers.
  - UI (`file:tags()`) reads tags without cache, so icons/linemodes update immediately after tagging.
  - Filters use a cached path for speed: `filter --tags=Red[,Blue] [--tag-all] [--deep --levels=N]`.

- Theme (visuals)
  - Tag icons/colors are defined in `theme.toml` via icon conditions, e.g.:
    - `{ if = "tag:red", text = "●", fg = "#ee7b70" }`
  - Use lowercase in the condition: matching is case‑insensitive.
  - Theme is now the single source of visuals; no Lua icon override.

- Plugin (behavior)
  - `mactag-unified` only provides tag apply/clear actions (no state, no fetchers).
  - It enforces a mutually‑exclusive set of “managed” tags and maps key names → macOS labels:
    - `MANAGED_TAGS = { ["red"] = "Red", ["green"] = "Green", ... }`
  - Keymaps call, for example: `plugin mactag-unified red`.

- Adding a new tag (both visuals + keybinding)
  1) Theme: add an icon rule in `theme.toml` (icon/fg you like), e.g. `{ if = "tag:mytag", text = "●", fg = "#abcdef" }`.
  2) Plugin: add an entry in `MANAGED_TAGS` (key → exact macOS label) and a keymap that calls `plugin mactag-unified <key>`.

- Notes
  - Preview and manager show tags on first render (no need to enter directories).
  - If you only want visuals (no keybinding/behavior), the theme change alone is enough.
  - Non‑macOS: tag conditions won’t match; `--tags` filter yields no matches.
