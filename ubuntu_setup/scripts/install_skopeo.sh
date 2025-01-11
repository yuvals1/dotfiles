#!/usr/bin/env bash
#
# Installs skopeo via apt.

run_install_skopeo() {
    if command_exists skopeo; then
        exists "skopeo already installed"
        return 0
    fi

    log "Installing skopeo..."
    sudo apt install -y skopeo || error "Failed to install skopeo"
    success "skopeo installed successfully"
}

