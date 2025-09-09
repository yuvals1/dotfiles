#!/usr/bin/env bash
#
# Installs hexyl (hex viewer).
#
run_install_hexyl() {
    if command_exists hexyl; then
        exists "hexyl already installed"
        return 0
    fi

    log "Installing hexyl..."
    
    # Install using GitHub releases
    local HEXYL_VERSION="v0.16.0"
    local ARCH="x86_64"
    if [ "$(uname -m)" = "aarch64" ]; then
        ARCH="aarch64"
    fi
    
    # hexyl uses gnu, not musl, and includes version in filename
    local DOWNLOAD_URL="https://github.com/sharkdp/hexyl/releases/download/${HEXYL_VERSION}/hexyl-${HEXYL_VERSION}-${ARCH}-unknown-linux-gnu.tar.gz"
    local TEMP_DIR=$(mktemp -d)
    
    wget -q "$DOWNLOAD_URL" -O "$TEMP_DIR/hexyl.tar.gz" || error "Failed to download hexyl"
    tar -xzf "$TEMP_DIR/hexyl.tar.gz" -C "$TEMP_DIR" || error "Failed to extract hexyl"
    
    # Find the hexyl binary (likely in hexyl-*/hexyl)
    local HEXYL_BIN=$(find "$TEMP_DIR" -name "hexyl" -type f -executable | head -1)
    if [ -z "$HEXYL_BIN" ]; then
        HEXYL_BIN=$(find "$TEMP_DIR" -name "hexyl" -type f | head -1)
    fi
    
    if [ -z "$HEXYL_BIN" ]; then
        error "Failed to find hexyl binary in extracted archive"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    sudo mv "$HEXYL_BIN" /usr/local/bin/hexyl || error "Failed to install hexyl"
    sudo chmod +x /usr/local/bin/hexyl
    
    rm -rf "$TEMP_DIR"

    success "hexyl installed successfully"
}