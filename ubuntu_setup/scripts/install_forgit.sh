#!/usr/bin/env bash
#
# Installs forgit for interactive git commands.

run_install_forgit() {
    # Check if forgit is already installed
    if [ -d "$HOME/.forgit" ]; then
        exists "forgit already installed"
        return 0
    fi

    log "Installing forgit..."
    
    # Clone forgit repository
    git clone https://github.com/wfxr/forgit.git "$HOME/.forgit"

    success "forgit installed successfully"
}
