#!/usr/bin/env bash
#
# Creates any directories needed for the setup.

run_setup_directories() {
    log "Setting up directories..."
    mkdir -p "$HOME/.zsh/tools"
    mkdir -p "$HOME/.local/bin"
    success "Directories created"
}

