#!/usr/bin/env bash
#
# Installs Zinit (Zsh plugin manager).
#
run_install_zinit() {
    if [ -d "$HOME/.local/share/zinit/zinit.git" ]; then
        exists "Zinit already installed"
        return 0
    fi

    log "Installing Zinit..."
    
    # Create directory and clone
    mkdir -p "$HOME/.local/share/zinit"
    git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.local/share/zinit/zinit.git" >/dev/null 2>&1 || error "Failed to install Zinit"
    
    success "Zinit installed successfully"
}