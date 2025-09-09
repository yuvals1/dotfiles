#!/usr/bin/env bash
#
# Installs csvq (SQL query tool for CSV files).

run_install_csvq() {
    if command_exists csvq; then
        exists "csvq already installed"
        return 0
    fi

    log "Installing csvq..."
    
    # Install using GitHub releases
    local CSVQ_VERSION="v1.18.1"
    local ARCH="amd64"
    if [ "$(uname -m)" = "aarch64" ]; then
        ARCH="arm64"
    fi
    
    local DOWNLOAD_URL="https://github.com/mithrandie/csvq/releases/download/${CSVQ_VERSION}/csvq-${CSVQ_VERSION}-linux-${ARCH}.tar.gz"
    local TEMP_DIR=$(mktemp -d)
    
    wget -q "$DOWNLOAD_URL" -O "$TEMP_DIR/csvq.tar.gz" || error "Failed to download csvq"
    tar -xzf "$TEMP_DIR/csvq.tar.gz" -C "$TEMP_DIR" || error "Failed to extract csvq"
    
    # Find the csvq binary (it might be in a subdirectory)
    local CSVQ_BIN=$(find "$TEMP_DIR" -name "csvq" -type f -executable | head -1)
    if [ -z "$CSVQ_BIN" ]; then
        # If no executable found, look for any csvq file
        CSVQ_BIN=$(find "$TEMP_DIR" -name "csvq" -type f | head -1)
    fi
    
    if [ -z "$CSVQ_BIN" ]; then
        error "Failed to find csvq binary in extracted archive"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    sudo mv "$CSVQ_BIN" /usr/local/bin/csvq || error "Failed to install csvq"
    sudo chmod +x /usr/local/bin/csvq
    
    rm -rf "$TEMP_DIR"

    success "csvq installed successfully"
}