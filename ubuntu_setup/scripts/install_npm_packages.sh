#!/usr/bin/env bash
#
# Installs global npm packages.
#
run_install_npm_packages() {
    log "Installing global npm packages..."
    
    # Load nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    npm install -g @openai/codex @anthropic-ai/claude-code
    
    success "Global npm packages installed"
}