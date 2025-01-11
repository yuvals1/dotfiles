#!/usr/bin/env bash
#
# Installs ccze via apt (for colorizing log output).

run_install_ccze() {
    if command_exists ccze; then
        exists "ccze already installed"
        return 0
    fi

    log "Installing ccze..."
    sudo apt install -y ccze || error "Failed to install ccze"
    success "ccze installed successfully"
}

