#!/bin/bash

# ────────────────────────────────────
# ▸ Configuration
# ────────────────────────────────────

FONT="SF Pro"

# ────────────────────────────────────
# ▸ Items
# ────────────────────────────────────

spotify_anchor=(
  script="$PLUGIN_DIR/spotify_display.sh"
  icon.drawing=off
  label.drawing=on
  label.max_chars=25
  label.scroll_texts=on
  label.font="$FONT:Semibold:15.0"
  label.color=$WHITE
  drawing=off
  y_offset=0
  updates=on
)

# Popup items removed - no longer needed

# ────────────────────────────────────
# ▸ Album Art Item (in menu bar)
# ────────────────────────────────────

spotify_artwork=(
  script="$PLUGIN_DIR/spotify_display.sh"
  label.drawing=off
  icon.drawing=off
  padding_left=2
  padding_right=2
  background.image.scale=0.18
  background.image.drawing=on
  background.drawing=on
  background.height=24
  background.corner_radius=4
  drawing=off
  y_offset=0
  updates=on
)

# ────────────────────────────────────
# ▸ Menu Bar Controls
# ────────────────────────────────────

spotify_menubar_controls=(
  script="$PLUGIN_DIR/spotify_display.sh"
  click_script="$PLUGIN_DIR/spotify_menubar_click.sh"
  label.drawing=off
  icon.drawing=on
  icon.font="$FONT:Regular:16.0"
  icon="🔀 🔁 ⏸"
  drawing=off
  y_offset=0
  updates=on
)

# ────────────────────────────────────
# ▸ Progress Bar (in menu bar)
# ────────────────────────────────────

spotify_progress=(
  script="$PLUGIN_DIR/spotify_display.sh"
  label.drawing=on
  label.font="$FONT:Semibold:13.0"
  label.color=$WHITE
  label.padding_left=8
  icon.drawing=on
  icon.font="$FONT:Semibold:13.0"
  icon.color=$WHITE
  icon.padding_right=8
  slider.background.height=4
  slider.background.corner_radius=2
  slider.background.color=0x40ffffff
  slider.highlight_color=$ACCENT_COLOR
  slider.percentage=0
  slider.width=80
  drawing=off
  y_offset=0
  update_freq=30
  updates=on
)

# ────────────────────────────────────
# ▸ SketchyBar Setup
# ────────────────────────────────────

# Register custom spotify event
sketchybar --add event spotify_update

# Add items from right to left (controls, progress, title, artwork)
sketchybar --add item spotify.menubar_controls center                  \
           --set spotify.menubar_controls "${spotify_menubar_controls[@]}" \
           --subscribe spotify.menubar_controls spotify_update        \
                                                                     \
           --add slider spotify.progress center                      \
           --set spotify.progress "${spotify_progress[@]}"           \
           --subscribe spotify.progress spotify_update               \
                                                                     \
           --add item spotify.anchor center                           \
           --set spotify.anchor "${spotify_anchor[@]}"               \
           --subscribe spotify.anchor spotify_update                 \
                                                                     \
           --add item spotify.artwork center                          \
           --set spotify.artwork "${spotify_artwork[@]}"             \
           --subscribe spotify.artwork spotify_update
