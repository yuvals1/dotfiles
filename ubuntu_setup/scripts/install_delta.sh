#!/usr/bin/env bash
#
# Installs git-delta (https://github.com/dandavison/delta)

run_install_delta() {
    if command_exists delta; then
        exists "delta already installed"
        return 0
    fi

    log "Installing delta..."

    # Try apt first (available in newer Ubuntu versions)
    if sudo apt install -y git-delta 2>/dev/null; then
        success "delta installed via apt"
        return 0
    fi

    # Fall back to manual installation from GitHub releases
    log "Installing delta from GitHub releases..."
    
    # Detect architecture
    local arch
    case $(uname -m) in
        x86_64) arch="x86_64" ;;
        aarch64) arch="arm64" ;;
        *) error "Unsupported architecture: $(uname -m)"; return 1 ;;
    esac

    # Get latest version
    local version
    version=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
    
    if [ -z "$version" ]; then
        error "Failed to get latest delta version"
        return 1
    fi

    # Download and install
    local temp_dir
    temp_dir=$(mktemp -d)
    pushd "$temp_dir" >/dev/null || error "Failed to enter temp directory"

    local package_name="git-delta_${version}_${arch}.deb"
    local download_url="https://github.com/dandavison/delta/releases/download/${version}/${package_name}"
    
    log "Downloading from: $download_url"
    if ! curl -L -o "$package_name" "$download_url"; then
        error "Failed to download delta package"
        popd >/dev/null
        rm -rf "$temp_dir"
        return 1
    fi

    if ! sudo dpkg -i "$package_name" >/dev/null 2>&1; then
        error "Failed to install delta package"
        popd >/dev/null
        rm -rf "$temp_dir"
        return 1
    fi

    popd >/dev/null
    rm -rf "$temp_dir"

    # Verify installation
    if ! command_exists delta; then
        error "Delta installation failed"
        return 1
    fi

    # Configure git to use delta
    git config --global core.pager "delta"
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate true
    git config --global delta.light false
    git config --global delta.side-by-side true
    git config --global delta.line-numbers true
    git config --global merge.conflictstyle "diff3"
    git config --global diff.colorMoved "default"

    success "delta installed and configured successfully"
}
