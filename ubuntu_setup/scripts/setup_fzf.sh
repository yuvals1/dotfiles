#!/usr/bin/env bash
#
# Sets up fzf key-bindings and completion for ZSH.

# Check if fzf needs updating or installing from source
check_fzf_version() {
    if command -v fzf >/dev/null 2>&1; then
        local version=$(fzf --version | cut -d' ' -f1)
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

# Install fzf from source
install_fzf_source() {
    log "Installing fzf from source..."
    
    # Remove existing package manager version if present
    if command -v apt >/dev/null 2>&1 && dpkg -l | grep -q "^ii  fzf "; then
        log "Removing package manager version of fzf..."
        sudo apt remove -y fzf
    fi

    # Clone and install fzf
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all --no-update-rc
    
    local version=$(fzf --version | cut -d' ' -f1)
    success "fzf version $version installed successfully"
}

run_setup_fzf() {
    # First check and install/update fzf if needed
    if ! check_fzf_version; then
        install_fzf_source
    fi

    # Then set up ZSH configuration
    if [ -f "$HOME/.zsh/tools/fzf/key-bindings.zsh" ] && [ -f "$HOME/.zsh/tools/fzf/completion.zsh" ]; then
        exists "fzf ZSH configuration already exists"
        return
    fi

    log "Setting up fzf ZSH configuration..."
    mkdir -p "$HOME/.zsh/tools/fzf"

    curl -fLo "$HOME/.zsh/tools/fzf/key-bindings.zsh" \
        "https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh"
    curl -fLo "$HOME/.zsh/tools/fzf/completion.zsh" \
        "https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh"

    if ! grep -q "source ~/.zsh/tools/fzf/key-bindings.zsh" "$HOME/.zshrc"; then
        echo "source ~/.zsh/tools/fzf/key-bindings.zsh" >>"$HOME/.zshrc"
        echo "source ~/.zsh/tools/fzf/completion.zsh" >>"$HOME/.zshrc"
    fi

    success "fzf ZSH configuration completed"
}
