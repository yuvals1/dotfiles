#!/usr/bin/env bash
#
# Installs glow (markdown renderer).

run_install_glow() {
    if command_exists glow; then
        exists "glow already installed"
        return 0
    fi

    log "Installing glow..."
    
    # Install using GitHub releases
    local GLOW_VERSION="v1.5.1"
    local ARCH="amd64"
    if [ "$(uname -m)" = "aarch64" ]; then
        ARCH="arm64"
    fi
    
    local DOWNLOAD_URL="https://github.com/charmbracelet/glow/releases/download/${GLOW_VERSION}/glow_Linux_${ARCH}.tar.gz"
    local TEMP_DIR=$(mktemp -d)
    
    wget -q "$DOWNLOAD_URL" -O "$TEMP_DIR/glow.tar.gz" || error "Failed to download glow"
    tar -xzf "$TEMP_DIR/glow.tar.gz" -C "$TEMP_DIR" || error "Failed to extract glow"
    sudo mv "$TEMP_DIR/glow" /usr/local/bin/ || error "Failed to install glow"
    sudo chmod +x /usr/local/bin/glow
    
    rm -rf "$TEMP_DIR"

    success "glow installed successfully"
}