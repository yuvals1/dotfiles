#!/usr/bin/env bash
#
# Installs lazydocker on arm64. Adjust for amd64 if needed.

run_install_lazydocker() {
    if command_exists lazydocker; then
        exists "lazydocker already installed"
        return
    fi

    log "Installing lazydocker..."
    local LAZYDOCKER_VERSION
    LAZYDOCKER_VERSION="$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" \
        | grep -Po '"tag_name": "v\K[^"]*')"

    curl -Lo lazydocker.tar.gz \
      "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_arm64.tar.gz"
    tar xf lazydocker.tar.gz
    sudo install lazydocker /usr/local/bin
    rm lazydocker lazydocker.tar.gz

    success "Lazydocker installed"
}

