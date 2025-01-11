#!/usr/bin/env bash
#
# Installs zoxide if not already present.

run_install_zoxide() {
    if command_exists zoxide; then
        exists "zoxide already installed"
        return
    fi

    log "Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    success "Zoxide installed"
}

