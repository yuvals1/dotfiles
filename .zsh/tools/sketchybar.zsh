#!/usr/bin/env zsh

# Sketchybar setup and functions

# Setup sketchybar fonts and permissions
setup_sketchybar() {
    # Only run on macOS
    [[ "$OSTYPE" != "darwin"* ]] && return
    
    # Install sketchybar-app-font if not already installed
    if [ ! -f "$HOME/Library/Fonts/sketchybar-app-font.ttf" ]; then
        echo "Installing sketchybar-app-font..."
        curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v1.0.16/sketchybar-app-font.ttf -o "$HOME/Library/Fonts/sketchybar-app-font.ttf"
    fi
    
    # Make sketchybar scripts executable
    if [ -d "$HOME/.config/sketchybar" ]; then
        chmod +x "$HOME/.config/sketchybar/sketchybarrc" 2>/dev/null || true
        [ -f "$HOME/.config/sketchybar/colors.sh" ] && chmod +x "$HOME/.config/sketchybar/colors.sh"
        [ -d "$HOME/.config/sketchybar/plugins" ] && chmod +x "$HOME/.config/sketchybar/plugins/"* 2>/dev/null || true
        [ -d "$HOME/.config/sketchybar/items" ] && chmod +x "$HOME/.config/sketchybar/items/"* 2>/dev/null || true
    fi
}

# Run setup if sketchybar is installed
if command -v sketchybar &> /dev/null; then
    setup_sketchybar
fi