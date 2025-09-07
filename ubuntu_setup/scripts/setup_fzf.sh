#!/usr/bin/env bash
#
# Sets up fzf key-bindings and completion for ZSH with improved PATH handling.

# Check if fzf needs updating or installing from source
check_fzf_version() {
    if command -v fzf >/dev/null 2>&1; then
        local version
        version=$(fzf --version | cut -d' ' -f1)
        if [ "$(printf '%s\n' "0.50.0" "$version" | sort -V | head -n1)" = "0.50.0" ]; then
            exists "fzf version $version is already installed and meets requirements"
            return 0
        fi
        log "Found fzf version $version - needs upgrading"
        return 1
    fi
    log "fzf not found - needs installing"
    return 1
}

# Setup fzf PATH (no longer modifies shell configs)
setup_fzf_path() {
    # Just export PATH for current session
    export PATH="$HOME/.fzf/bin:$PATH"
}

# Install fzf from source
install_fzf_source() {
    log "Installing fzf from source..."
    
    # Remove existing package manager version if present
    if command -v apt >/dev/null 2>&1 && dpkg -l | grep -q "^ii  fzf "; then
        log "Removing package manager version of fzf..."
        sudo apt remove -y fzf
    fi

    # Clean up existing installation if present
    if [ -d "$HOME/.fzf" ]; then
        log "Removing existing fzf installation..."
        rm -rf "$HOME/.fzf"
    fi

    # Clone and install fzf
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --all --no-update-rc

    # Setup PATH for current session
    setup_fzf_path
    
    # Verify installation
    if [ -x "$HOME/.fzf/bin/fzf" ]; then
        local version
        version=$("$HOME/.fzf/bin/fzf" --version | cut -d' ' -f1)
        success "fzf version $version installed successfully"
    else
        error "fzf installation failed - binary not found or not executable"
        return 1
    fi
}

# Setup fzf configuration for ZSH
setup_zsh_config() {
    local config_dir="$HOME/.zsh/tools/fzf"
    mkdir -p "$config_dir"

    # Download key-bindings and completion files
    curl -fLo "$config_dir/key-bindings.zsh" \
        "https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh"
    curl -fLo "$config_dir/completion.zsh" \
        "https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh"
}

run_setup_fzf() {
    # First check and install/update fzf if needed
    if ! check_fzf_version; then
        install_fzf_source || return 1
    fi

    # Then set up ZSH configuration
    if [ -f "$HOME/.zsh/tools/fzf/key-bindings.zsh" ] && [ -f "$HOME/.zsh/tools/fzf/completion.zsh" ]; then
        exists "fzf ZSH configuration already exists"
    else
        log "Setting up fzf ZSH configuration..."
        setup_zsh_config
        success "fzf ZSH configuration completed"
    fi

    success "fzf setup completed"
}
