# Auto-install notify command function
# This creates a notify function that builds and installs the notify-cli tool if needed

function notify() {
    local NOTIFY_BIN="$HOME/.local/bin/notify"
    local NOTIFY_SRC="$HOME/dotfiles/tools/notify-cli"
    
    # Create ~/.local/bin if it doesn't exist
    [[ ! -d "$HOME/.local/bin" ]] && mkdir -p "$HOME/.local/bin"
    
    # Build and install if binary doesn't exist
    if [[ ! -f "$NOTIFY_BIN" ]]; then
        if command -v cargo &> /dev/null; then
            echo "Building notify-cli for first time use..."
            (
                cd "$NOTIFY_SRC" && \
                cargo build --release --quiet && \
                cp target/release/notify-cli "$NOTIFY_BIN" && \
                rm -rf target
            )
            if [[ $? -eq 0 ]]; then
                echo "notify-cli installed successfully!"
            else
                echo "Failed to build notify-cli" >&2
                return 1
            fi
        else
            echo "Rust/Cargo not found. Please install Rust to use notify command." >&2
            return 1
        fi
    fi
    
    # Run the notify command with all arguments
    "$NOTIFY_BIN" "$@"
}

# Alias for convenience
alias noti='notify'