#!/usr/bin/env bash
#
# Installs Node.js 20 via nvm.

run_install_node() {
    # Check if nvm is installed
    if [ -d "$HOME/.nvm" ]; then
        exists "nvm already installed"

        # Load nvm
        export NVM_DIR="$HOME/.nvm"
        # shellcheck source=/dev/null
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

        # Check if Node 20 is installed
        if nvm ls | grep -q "v20"; then
            exists "Node.js 20 already installed"
            return
        fi
    else
        log "Installing nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

        # Load nvm
        export NVM_DIR="$HOME/.nvm"
        # shellcheck source=/dev/null
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi

    # Install Node.js 20
    log "Installing Node.js 20..."
    nvm install 20
    nvm use 20
    nvm alias default 20

    success "Node.js setup completed"
}

