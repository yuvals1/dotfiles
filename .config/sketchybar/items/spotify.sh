#!/bin/bash

# ────────────────────────────────────
# ▸ Configuration
# ────────────────────────────────────

FONT="SF Pro"

# ────────────────────────────────────
# ▸ Items
# ────────────────────────────────────

spotify_anchor=(
  icon.drawing=on
  icon.font="sketchybar-app-font:Regular:16.0"
  icon=":spotify:"
  icon.color=$SPOTIFY_GREEN
  icon.padding_right=8
  label.drawing=on
  label.max_chars=25
  label.scroll_texts=on
  label.font="$FONT:Semibold:15.0"
  label.color=$WHITE
  y_offset=0
  updates=on
)

# ────────────────────────────────────
# ▸ Context/Radio Mode Item
# ────────────────────────────────────

spotify_context=(
  icon.drawing=off
  icon.font="$FONT:Regular:16.0"
  icon.color=$WHITE
  icon.padding_right=4
  label.drawing=on
  label.font="$FONT:Semibold:15.0"
  label.color=$WHITE
  label.padding_left=0
  label.padding_right=8
  y_offset=0
  updates=on
)

# ────────────────────────────────────
# ▸ Album Art Item (in menu bar)
# ────────────────────────────────────

spotify_artwork=(
  label.drawing=off
  icon.drawing=off
  padding_left=2
  padding_right=2
  background.image.scale=0.18
  background.image.drawing=on
  background.drawing=on
  background.height=24
  background.corner_radius=4
  y_offset=0
  updates=on
)

# ────────────────────────────────────
# ▸ Menu Bar Controls
# ────────────────────────────────────

spotify_menubar_controls=(
  click_script="$PLUGIN_DIR/spotify_menubar_click.sh"
  label.drawing=off
  icon.drawing=on
  icon.font="$FONT:Regular:16.0"
  icon="🔀 🔁 ⏸"
  y_offset=0
  updates=on
)

# ────────────────────────────────────
# ▸ Progress Bar (in menu bar)
# ────────────────────────────────────

spotify_progress=(
  label.drawing=on
  label.font="$FONT:Semibold:13.0"
  label.color=$WHITE
  label.padding_left=8
  label.width=48
  icon.drawing=on
  icon.font="$FONT:Semibold:13.0"
  icon.color=$WHITE
  icon.padding_right=8
  icon.width=48
  slider.background.height=4
  slider.background.corner_radius=2
  slider.background.color=0x40ffffff
  slider.highlight_color=$ACCENT_COLOR
  slider.percentage=0
  slider.width=80
  y_offset=0
  update_freq=30
  updates=on
)

# ────────────────────────────────────
# ▸ SketchyBar Setup
# ────────────────────────────────────

# Register custom spotify event
sketchybar --add event spotify_update

# ────────────────────────────────────
# ▸ Simple daemon check - if off, only show anchor with "Spotify Stopped"
# ────────────────────────────────────

DAEMON_RUNNING=$(pgrep -f "spotify.sh|spotify_player" | head -1)

# Add items - all hidden by default except anchor when daemon is off
sketchybar --add item spotify.menubar_controls center                  \
           --set spotify.menubar_controls "${spotify_menubar_controls[@]}" drawing=off \
           --subscribe spotify.menubar_controls spotify_update        \
                                                                     \
           --add slider spotify.progress center                      \
           --set spotify.progress "${spotify_progress[@]}" drawing=off \
           --subscribe spotify.progress spotify_update               \
                                                                     \
           --add item spotify.context center                          \
           --set spotify.context "${spotify_context[@]}" drawing=off \
           --subscribe spotify.context spotify_update                 \
                                                                     \
           --add item spotify.anchor center                           \
           --set spotify.anchor "${spotify_anchor[@]}" \
           --subscribe spotify.anchor spotify_update                 \
                                                                     \
           --add item spotify.artwork center                          \
           --set spotify.artwork "${spotify_artwork[@]}" drawing=off \
           --subscribe spotify.artwork spotify_update

# If daemon not running, show "Spotify Stopped" on anchor
if [ -z "$DAEMON_RUNNING" ]; then
  sketchybar --set spotify.anchor drawing=on label="Spotify Stopped"
fi
