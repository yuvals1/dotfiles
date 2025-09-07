#!/usr/bin/env bash
#
# Installs btop from prebuilt binaries.
#
run_install_btop() {
    if command_exists btop; then
        exists "btop already installed"
        return 0
    fi

    log "Installing btop from prebuilt binary..."
    
    # Detect architecture
    local arch
    arch=$(uname -m)
    local btop_arch
    
    case "$arch" in
        x86_64)
            btop_arch="x86_64"
            ;;
        aarch64|arm64)
            btop_arch="aarch64"
            ;;
        i686)
            btop_arch="i686"
            ;;
        i486)
            btop_arch="i486"
            ;;
        *)
            error "Unsupported architecture for btop: $arch"
            return 1
            ;;
    esac
    
    # Download and install btop
    local temp_dir
    temp_dir=$(mktemp -d)
    cd "$temp_dir" || error "Failed to create temp directory"
    
    log "Downloading btop for $btop_arch..."
    wget -q "https://github.com/aristocratos/btop/releases/latest/download/btop-${btop_arch}-linux-musl.tbz" || error "Failed to download btop"
    
    # Extract
    tar -xjf "btop-${btop_arch}-linux-musl.tbz" || error "Failed to extract btop"
    
    # Install using the included Makefile
    cd btop || error "Failed to enter btop directory"
    sudo make install || error "Failed to install btop"
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$temp_dir"

    if command_exists btop; then
        success "btop installed successfully"
    else
        error "btop installation failed"
    fi
}