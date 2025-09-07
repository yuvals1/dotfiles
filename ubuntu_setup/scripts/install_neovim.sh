#!/usr/bin/env bash
#
# Installs Neovim from prebuilt binaries.
#
run_install_neovim() {
    if command_exists nvim; then
        local current_version
        current_version=$(nvim --version | head -n1)
        exists "Neovim already installed: $current_version"
        return 0
    fi

    log "Installing Neovim from prebuilt binaries..."
    
    # Detect architecture
    local arch
    arch=$(uname -m)
    local nvim_arch
    
    case "$arch" in
        x86_64)
            nvim_arch="linux-x86_64"
            ;;
        aarch64|arm64)
            nvim_arch="linux-arm64"
            ;;
        *)
            error "Unsupported architecture: $arch"
            return 1
            ;;
    esac
    
    # Download the appropriate tarball
    local temp_dir
    temp_dir=$(mktemp -d)
    pushd "$temp_dir" >/dev/null || error "Failed to create temp directory"
    
    log "Downloading Neovim for $nvim_arch..."
    wget -q "https://github.com/neovim/neovim/releases/download/nightly/nvim-${nvim_arch}.tar.gz" || error "Failed to download Neovim"
    
    # Extract and install
    log "Extracting Neovim..."
    tar xzf "nvim-${nvim_arch}.tar.gz" || error "Failed to extract Neovim"
    
    # Move to /usr/local
    sudo rm -rf /usr/local/nvim
    sudo mv "nvim-${nvim_arch}" /usr/local/nvim || error "Failed to install Neovim"
    
    # Create symlink
    sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/nvim || error "Failed to create nvim symlink"
    
    # Cleanup
    popd >/dev/null
    rm -rf "$temp_dir"

    if command_exists nvim; then
        local version
        version=$(nvim --version | head -n1)
        success "Neovim installed: $version"
    else
        error "Neovim installation failed"
    fi
}