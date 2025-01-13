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

# Add fzf to PATH in shell config files
setup_fzf_path() {
    local config_files=("$HOME/.zshrc" "$HOME/.bashrc")
    local path_entry='export PATH="$HOME/.fzf/bin:$PATH"'
    
    for config in "${config_files[@]}"; do
        if [ -f "$config" ]; then
            if ! grep -q "export PATH.*/.fzf/bin" "$config"; then
                log "Adding fzf to PATH in $config"
                # Add a newline if the file doesn't end with one
                [[ -s "$config" && -z "$(tail -c1 "$config")" ]] || echo '' >> "$config"
                echo "# fzf" >> "$config"
                echo "$path_entry" >> "$config"
            fi
        fi
    done
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

    # Setup PATH
    setup_fzf_path
    
    # Source the new PATH
    # shellcheck source=/dev/null
    source "$HOME/.zshrc" 2>/dev/null || source "$HOME/.bashrc" 2>/dev/null || export PATH="$HOME/.fzf/bin:$PATH"
    
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

    # Add source lines to .zshrc if not already present
    local zshrc="$HOME/.zshrc"
    if [ -f "$zshrc" ]; then
        for file in "key-bindings.zsh" "completion.zsh"; do
            if ! grep -q "source.*fzf/$file" "$zshrc"; then
                echo "source ~/.zsh/tools/fzf/$file" >> "$zshrc"
            fi
        done
    fi
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

    log "fzf setup completed. Please run 'source ~/.zshrc' to apply changes"
}
