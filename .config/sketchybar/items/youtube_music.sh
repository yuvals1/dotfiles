#!/bin/bash

# ────────────────────────────────────
# ▸ Configuration
# ────────────────────────────────────

FONT="SF Pro"

# ────────────────────────────────────
# ▸ Items
# ────────────────────────────────────

youtube_music_anchor=(
  script="$PLUGIN_DIR/youtube_music_display.sh"
  icon.drawing=on
  icon.font="sketchybar-app-font:Regular:16.0"
  icon=":youtube:"
  icon.color=$YOUTUBE_RED
  icon.padding_right=8
  label.drawing=on
  label.max_chars=25
  label.scroll_texts=on
  label.font="$FONT:Semibold:15.0"
  label.color=$WHITE
  drawing=off
  y_offset=0
  update_freq=2
  updates=on
)

youtube_music_artwork=(
  script="$PLUGIN_DIR/youtube_music_display.sh"
  label.drawing=off
  icon.drawing=off
  padding_left=2
  padding_right=2
  background.image.scale=0.08
  background.image.drawing=on
  background.drawing=on
  background.height=24
  background.corner_radius=4
  drawing=off
  y_offset=0
  updates=on
)

youtube_music_progress=(
  script="$PLUGIN_DIR/youtube_music_display.sh"
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
  update_freq=2
  updates=on
)

youtube_music_controls=(
  script="$PLUGIN_DIR/youtube_music_display.sh"
  click_script="$PLUGIN_DIR/youtube_music_click.sh"
  label.drawing=off
  icon.drawing=on
  icon.font="$FONT:Regular:16.0"
  icon="▶️"
  drawing=off
  y_offset=0
  updates=on
)

# ────────────────────────────────────
# ▸ SketchyBar Setup
# ────────────────────────────────────

# Register custom youtube music event
sketchybar --add event youtube_music_update

# Add items from right to left (controls, progress, title, artwork)
sketchybar --add item youtube_music.controls center                  \
           --set youtube_music.controls "${youtube_music_controls[@]}" \
           --subscribe youtube_music.controls youtube_music_update    \
                                                                     \
           --add slider youtube_music.progress center                \
           --set youtube_music.progress "${youtube_music_progress[@]}" \
           --subscribe youtube_music.progress youtube_music_update   \
                                                                     \
           --add item youtube_music.anchor center                    \
           --set youtube_music.anchor "${youtube_music_anchor[@]}"    \
           --subscribe youtube_music.anchor youtube_music_update     \
                                                                     \
           --add item youtube_music.artwork center                   \
           --set youtube_music.artwork "${youtube_music_artwork[@]}"  \
           --subscribe youtube_music.artwork youtube_music_update