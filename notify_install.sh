#!/bin/bash

# Install script for notify-cli

NOTIFY_BIN="$HOME/.local/bin/notify"
NOTIFY_SRC="$HOME/dotfiles/tools/notify-cli"

echo "Installing notify-cli..."

# Create ~/.local/bin if it doesn't exist
mkdir -p "$HOME/.local/bin"

# Check if Rust is installed
if ! command -v cargo &> /dev/null; then
    echo "Error: Rust/Cargo not found. Please install Rust first."
    exit 1
fi

# Build and install
cd "$NOTIFY_SRC" || exit 1
echo "Building notify-cli..."
cargo build --release

if [ $? -eq 0 ]; then
    cp target/release/notify-cli "$NOTIFY_BIN"
    rm -rf target
    echo "Successfully installed notify to $NOTIFY_BIN"
    echo ""
    echo "Add this alias to your .zshrc or .zsh/aliases.zsh:"
    echo "alias notify='$NOTIFY_BIN'"
else
    echo "Build failed!"
    exit 1
fi