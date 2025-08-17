#!/bin/bash
source "$CONFIG_DIR/theme.sh"

# Check if SwitchAudioSource is available
if ! command -v SwitchAudioSource &> /dev/null; then
  sketchybar --set $NAME label="Install switchaudio-osx" icon="⚠️" icon.color="$ACCENT_COLOR"
  exit 0
fi

audio_device="$(SwitchAudioSource -c)"
color="$WHITE"

if [[ "$audio_device" == *"AirPods Max"* ]]; then
  icon=""
elif [[ "$audio_device" == *"AirPods Pro"* ]]; then
  icon="🎧"
elif [[ "$audio_device" == *"AirPods"* ]]; then
  icon=""
elif [[ "$audio_device" == *"Headphones"* ]]; then
  icon=""
elif [[ "$audio_device" == *"MacBook Pro Speakers"* ]] || [[ "$audio_device" == *"MacBook Air Speakers"* ]]; then
  icon="💻"
elif [[ "$audio_device" == *"Speakers"* ]]; then
  icon="󰓃"
else
  icon="󱄡"
  color="$ACCENT_COLOR"
fi

sketchybar --set $NAME icon="$icon" icon.color="$color" label=""
