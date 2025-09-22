#!/usr/bin/env bash
#
# Installs Go (golang) on Ubuntu via apt.
# Tries golang-go first (meta package), falls back to golang.

run_install_go() {
    if command -v go >/dev/null 2>&1; then
        exists "Go already installed: $(go version)"
        return
    fi

    log "Installing Go (golang)..."
    sudo apt update -y || error "Failed to apt update"
    if sudo apt install -y golang-go; then
        success "Installed golang-go"
    else
        warn "golang-go not available; trying 'golang' package"
        sudo apt install -y golang || error "Failed to install Go"
    fi

    if command -v go >/dev/null 2>&1; then
        success "Go installed: $(go version)"
    else
        error "Go not found after installation"
    fi
}
