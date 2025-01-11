#!/usr/bin/env bash
#
# Installs ncdu via apt.

run_install_ncdu() {
    if command_exists ncdu; then
        exists "ncdu already installed"
        return 0
    fi

    log "Installing ncdu..."
    sudo apt install -y ncdu || error "Failed to install ncdu"
    success "ncdu installed successfully"
}

