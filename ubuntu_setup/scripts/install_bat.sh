#!/usr/bin/env bash
#
# Installs bat (or sets up symlink if only batcat is available).

run_install_bat() {
    if command_exists bat; then
        exists "bat already installed"
        return 0
    fi

    log "Installing bat..."
    sudo apt install -y bat || error "Failed to install bat"

    # Create bat -> batcat symlink if it doesn't exist
    if [ ! -f "/usr/local/bin/bat" ] && command_exists batcat; then
        log "Creating bat symlink..."
        sudo ln -s /usr/bin/batcat /usr/local/bin/bat
    fi

    success "bat installed successfully"
}

