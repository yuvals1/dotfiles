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
        return 0
    fi

    if command_exists cargo; then
        log "Attempting cargo install of Nushell..."
        if cargo install --locked nu >/dev/null 2>&1; then
            success "Nushell installed successfully via cargo"
            return 0
        fi
        error "Cargo install of Nushell failed"
    else
        error "Cargo not available to install Nushell"
    fi

    error "Failed to install Nushell"
    return 1
}
