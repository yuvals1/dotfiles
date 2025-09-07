#!/usr/bin/env bash
#
# Installs base packages as defined in packages.txt
#
run_install_base_packages() {
    log "Checking and installing packages from packages.txt..."

    # Remove problematic repository to avoid apt update errors
    sudo rm -f /etc/apt/sources.list.d/nodesource.list

    # Update package list quietly
    sudo apt update -qq >/dev/null 2>&1

    local installed_count=0
    local skipped_count=0

    while read -r package || [ -n "$package" ]; do
        # Skip comments and empty lines
        [[ $package =~ ^#.*$ ]] || [ -z "$package" ] && continue

        if dpkg -l 2>/dev/null | grep -q "^ii  $package "; then
            ((skipped_count++))
        else
            log "Installing $package..."
            if sudo apt install -y -qq "$package" >/dev/null 2>&1; then
                ((installed_count++))
            else
                error "Failed to install $package"
            fi
        fi
    done <"$SCRIPT_DIR/packages.txt"

    success "Base packages: $installed_count installed, $skipped_count already present"
}