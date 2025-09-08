#!/usr/bin/env bash
#
# Installs zoxide if not already present.

run_install_zoxide() {
    log "Installing latest zoxide (forcing update)..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    success "Zoxide installed/updated"
}

