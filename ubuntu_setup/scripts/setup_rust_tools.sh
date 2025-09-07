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

    # Build and install yazi from local source
    if ! command_exists ya || ! command_exists yazi; then
        log "Building yazi from local source..."
        
        # Clone or update the yazi repository
        if [ ! -d "$HOME/dev/yazi" ]; then
            log "Cloning yazi repository..."
            mkdir -p "$HOME/dev"
            git clone https://github.com/yuvals1/yazi.git "$HOME/dev/yazi" || error "Failed to clone yazi repository"
        fi
        
        # Checkout the yuval branch and build
        cd "$HOME/dev/yazi" || error "Failed to navigate to yazi directory"
        git fetch origin || error "Failed to fetch from origin"
        git checkout yuval || error "Failed to checkout yuval branch"
        git pull origin yuval || true  # Pull latest changes if possible
        
        log "Building yazi-fm and yazi-cli..."
        cargo build --release || error "Failed to build yazi"
        
        # Create symlinks to the built binaries instead of installing via cargo
        log "Creating symlinks for yazi binaries..."
        sudo ln -sf "$HOME/dev/yazi/target/release/yazi" /usr/local/bin/yazi
        sudo ln -sf "$HOME/dev/yazi/target/release/ya" /usr/local/bin/ya
        
        cd - > /dev/null  # Return to previous directory
    else
        exists "yazi and ya already installed"
    fi

    success "Rust tools installation completed"
}

