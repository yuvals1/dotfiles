#!/usr/bin/env bash
#
# Installs and sets up Rust + eza + yazi + ya.

run_setup_rust_tools() {
    # If eza, yazi, and ya exist, skip
    if command_exists eza && command_exists yazi && command_exists ya; then
        exists "All Rust tools already installed"
        return 0
    fi

    # Install Rust if not already installed
    if ! command_exists rustc; then
        log "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        rustup default stable
    else
        exists "Rust already installed"
    fi

    # Ensure we have the stable toolchain
    if ! rustup show active-toolchain | grep -q "stable"; then
        log "Setting up stable Rust toolchain..."
        rustup default stable
    fi

    log "Setting up Rust tools..."
    source "$HOME/.cargo/env" || true

    # Install eza
    if command_exists eza; then
        exists "eza already installed"
    else
        log "Installing eza..."
        cargo install eza || error "Failed to install eza"
    fi

    # Install yazi and ya CLI
    if ! command_exists ya || ! command_exists yazi; then
        log "Installing yazi and ya CLI..."
        cargo install --locked yazi-fm || error "Failed to install yazi-fm"
        cargo install --locked yazi-cli || error "Failed to install yazi-cli"

        # Create yazi config directory
        mkdir -p "$HOME/.config/yazi"

        # Initialize package.toml if it doesn't exist
        if [ ! -f "$HOME/.config/yazi/package.toml" ]; then
            echo '[plugin]' >"$HOME/.config/yazi/package.toml"
            echo 'deps = []' >>"$HOME/.config/yazi/package.toml"
        fi
    else
        exists "yazi and ya already installed"
    fi

    success "Rust tools installation completed"
}

