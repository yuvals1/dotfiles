#!/usr/bin/env bash
#
# Installs lazygit on arm64. Adjust for amd64 if needed.

run_install_lazygit() {
    if command_exists lazygit; then
        exists "lazygit already installed"
        return
    fi

    log "Installing lazygit..."
    local LAZYGIT_VERSION
    LAZYGIT_VERSION="$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
        | grep -Po '"tag_name": "v\K[^"]*')"

    curl -Lo lazygit.tar.gz \
      "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_arm64.tar.gz"
    tar xf lazygit.tar.gz
    sudo install lazygit /usr/local/bin
    rm lazygit lazygit.tar.gz

    success "Lazygit installed"
}

