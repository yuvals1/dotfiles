#!/usr/bin/env bash
#
# Installs fzf from prebuilt binaries and sets up shell configuration files.
#
run_setup_fzf() {
    if command_exists fzf; then
        local version
        version=$(fzf --version | cut -d' ' -f1)
        exists "fzf version $version already installed"
    else
        log "Installing fzf from prebuilt binary..."
        
        # Detect architecture
        local arch
        arch=$(uname -m)
        local fzf_arch
        
        case "$arch" in
            x86_64)
                fzf_arch="linux_amd64"
                ;;
            aarch64|arm64)
                fzf_arch="linux_arm64"
                ;;
            armv7l)
                fzf_arch="linux_armv7"
                ;;
            *)
                error "Unsupported architecture for fzf: $arch"
                return 1
                ;;
        esac
        
        # Get latest version
        local fzf_version
        fzf_version=$(curl -s "https://api.github.com/repos/junegunn/fzf/releases/latest" | grep -Po '"tag_name": "v?\K[^"]*')
        
        # Download and install fzf
        local temp_dir
        temp_dir=$(mktemp -d)
        pushd "$temp_dir" >/dev/null || error "Failed to create temp directory"
        
        log "Downloading fzf ${fzf_version} for ${fzf_arch}..."
        wget -q "https://github.com/junegunn/fzf/releases/download/v${fzf_version}/fzf-${fzf_version}-${fzf_arch}.tar.gz" || error "Failed to download fzf"
        
        # Extract
        tar -xzf "fzf-${fzf_version}-${fzf_arch}.tar.gz" || error "Failed to extract fzf"
        
        # Install binary
        sudo install -m 755 fzf /usr/local/bin/fzf || error "Failed to install fzf"
        
        # Cleanup
        popd >/dev/null
        rm -rf "$temp_dir"
        
        if command_exists fzf; then
            local version
            version=$(fzf --version | cut -d' ' -f1)
            success "fzf version $version installed successfully"
        else
            error "fzf installation failed"
        fi
    fi
    
    # Setup ZSH configuration files
    if [ -f "$HOME/.zsh/tools/fzf/key-bindings.zsh" ] && [ -f "$HOME/.zsh/tools/fzf/completion.zsh" ]; then
        exists "fzf ZSH configuration already exists"
    else
        log "Setting up fzf ZSH configuration..."
        local config_dir="$HOME/.zsh/tools/fzf"
        mkdir -p "$config_dir"
        
        # Download key-bindings and completion files
        curl -fLo "$config_dir/key-bindings.zsh" \
            "https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh"
        curl -fLo "$config_dir/completion.zsh" \
            "https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh"
        
        success "fzf ZSH configuration completed"
    fi
}