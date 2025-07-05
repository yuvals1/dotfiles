# notify-cli

A simple command-line notification tool for macOS that works reliably inside tmux/kitty.

## Usage

```bash
notify                    # Shows "Notification: Hello from CLI!"
notify "message"          # Shows "Notification: message"
notify "title" "message"  # Shows "title: message"
```

## Building

```bash
cd ~/dotfiles/tools/notify-cli
cargo build --release
cp target/release/notify-cli ~/dotfiles/bin/notify
```

## Why Rust?

This tool uses the `notify-rust` crate which directly interfaces with macOS's native notification API, bypassing terminal context issues that affect `terminal-notifier` and `osascript` when used inside tmux or certain terminal emulators.