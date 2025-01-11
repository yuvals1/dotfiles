#!/usr/bin/env bash
#
# Builds Neovim from source (stable branch).

run_install_neovim() {
    if command_exists nvim; then
        local current_version
        current_version=$(nvim --version | head -n1)
        exists "Neovim already installed: $current_version"
        read -p "Do you want to reinstall? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi

    log "Installing Neovim dependencies..."
    sudo apt install -y \
        ninja-build \
        gettext \
        cmake \
        unzip \
        curl \
        libsqlite3-dev \
        sqlite3 || error "Failed to install Neovim dependencies"

    log "Building Neovim from source..."
    local BUILD_DIR
    BUILD_DIR="$(mktemp -d)"
    cd "$BUILD_DIR" || exit 1

    git clone https://github.com/neovim/neovim
    cd neovim || exit 1
    git checkout stable
    make CMAKE_BUILD_TYPE=RelWithDebInfo
    sudo make install

    cd || exit 1
    rm -rf "$BUILD_DIR"

    if command_exists nvim; then
        success "Neovim installed!"
    else
        error "Neovim installation failed"
    fi
}

