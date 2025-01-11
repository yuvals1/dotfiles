#!/usr/bin/env bash
#
# Installs btop from source.

run_install_btop() {
    if command_exists btop; then
        exists "btop already installed"
        return
    fi

    log "Setting up required locales for btop..."
    sudo apt install -y locales
    sudo locale-gen en_US.UTF-8
    sudo update-locale LANG=en_US.UTF-8

    log "Installing btop..."
    local BUILD_DIR
    BUILD_DIR="$(mktemp -d)"
    cd "$BUILD_DIR" || exit 1

    git clone https://github.com/aristocratos/btop.git
    cd btop || exit 1
    make
    sudo make install

    cd || exit 1
    rm -rf "$BUILD_DIR"

    if command_exists btop; then
        success "btop installed!"
    else
        error "btop installation failed"
    fi
}

