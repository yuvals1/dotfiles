#!/usr/bin/env bash
#
# Installs Nushell (data-oriented shell).

run_install_nushell() {
    if command_exists nu; then
        exists "Nushell already installed"
        return 0
    fi

    log "Installing Nushell..."

    if sudo apt install -y nushell >/dev/null 2>&1; then
        success "Nushell installed successfully"
        return 0
    fi

    log "Initial install failed, refreshing apt cache..."
    if sudo apt update >/dev/null 2>&1 && sudo apt install -y nushell >/dev/null 2>&1; then
        success "Nushell installed successfully"
    else
        error "Failed to install Nushell"
        return 1
    fi
}
