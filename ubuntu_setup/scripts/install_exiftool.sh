#!/usr/bin/env bash
#
# Installs exiftool for EXIF data viewing.
#
run_install_exiftool() {
    if command_exists exiftool; then
        exists "exiftool already installed"
        return 0
    fi

    log "Installing exiftool..."
    sudo apt install -y -qq libimage-exiftool-perl >/dev/null 2>&1 || error "Failed to install exiftool"
    success "exiftool installed successfully"
}