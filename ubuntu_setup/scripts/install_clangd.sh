#!/usr/bin/env bash
#
# Installs clangd from the Ubuntu repositories when not already present.

run_install_clangd() {
    if command_exists clangd; then
        local current_version
        current_version=$(clangd --version | head -n1)
        exists "clangd already installed: $current_version"
        return 0
    fi

    log "Installing clangd via apt..."
    if sudo apt install -y -qq clangd >/dev/null 2>&1; then
        local installed_version
        installed_version=$(clangd --version | head -n1)
        success "clangd installed: $installed_version"
    else
        error "Failed to install clangd"
    fi
}
