#!/usr/bin/env bash
#
# Installs dependencies needed by yazi (fzf, zoxide, etc.),
# but the actual yazi installs happen in the Rust tools script.

run_install_yazi_deps() {
    log "Installing yazi dependencies..."
    sudo apt install -y -qq \
        file \
        ffmpeg \
        p7zip-full \
        jq \
        poppler-utils \
        fd-find \
        ripgrep \
        fzf \
        zoxide \
        imagemagick \
        xclip || error "Failed to install yazi dependencies"

    # Create fd symlink if needed (Debian/Ubuntu packages fd as fdfind)
    if ! command_exists fd && command_exists fdfind; then
        sudo ln -s "$(which fdfind)" /usr/local/bin/fd
    fi

    success "Yazi dependencies installed"
}

