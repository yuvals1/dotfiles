#!/usr/bin/env bash
#
# Installs VisiData (terminal data explorer).

run_install_visidata() {
    if command_exists vd; then
        exists "VisiData already installed"
        return 0
    fi

    log "Installing VisiData..."

    if ! command_exists pip3; then
        log "pip3 not found, installing python3-pip..."
        sudo apt update && sudo apt install -y python3-pip >/dev/null 2>&1 || {
            error "Failed to install pip3"
            return 1
        }
    fi

    if python3 -m pip install --user --upgrade visidata >/dev/null 2>&1; then
        hash -r 2>/dev/null || true
        if command_exists vd; then
            success "VisiData installed successfully"
        else
            log "VisiData installed, but vd not on PATH. Ensure ~/.local/bin is in PATH."
        fi
    else
        error "Failed to install VisiData"
        return 1
    fi
}
