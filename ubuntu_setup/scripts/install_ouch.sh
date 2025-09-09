#!/usr/bin/env bash
#
# Installs ouch (modern archive extraction/compression tool).
#
run_install_ouch() {
    if command_exists ouch; then
        exists "ouch already installed"
        return 0
    fi

    log "Installing ouch..."
    
    # Install using GitHub releases
    local OUCH_VERSION="0.5.1"
    local ARCH="x86_64"
    if [ "$(uname -m)" = "aarch64" ]; then
        ARCH="aarch64"
    fi
    
    local DOWNLOAD_URL="https://github.com/ouch-org/ouch/releases/download/${OUCH_VERSION}/ouch-${ARCH}-unknown-linux-musl.tar.gz"
    local TEMP_DIR=$(mktemp -d)
    
    wget -q "$DOWNLOAD_URL" -O "$TEMP_DIR/ouch.tar.gz" || error "Failed to download ouch"
    tar -xzf "$TEMP_DIR/ouch.tar.gz" -C "$TEMP_DIR" || error "Failed to extract ouch"
    
    # Find the ouch binary
    local OUCH_BIN=$(find "$TEMP_DIR" -name "ouch" -type f -executable | head -1)
    if [ -z "$OUCH_BIN" ]; then
        OUCH_BIN=$(find "$TEMP_DIR" -name "ouch" -type f | head -1)
    fi
    
    if [ -z "$OUCH_BIN" ]; then
        error "Failed to find ouch binary in extracted archive"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    sudo mv "$OUCH_BIN" /usr/local/bin/ouch || error "Failed to install ouch"
    sudo chmod +x /usr/local/bin/ouch
    
    rm -rf "$TEMP_DIR"

    success "ouch installed successfully"
}