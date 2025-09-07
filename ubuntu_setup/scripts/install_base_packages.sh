#!/usr/bin/env bash
#
# Installs base packages as defined in packages.txt

check_packages_status() {
    local need_install=false

    while read -r package || [ -n "$package" ]; do
        # Skip comments and empty lines
        [[ $package =~ ^#.*$ ]] || [ -z "$package" ] && continue

        # Check if package is installed
        if ! dpkg -l | grep -q "^ii  $package "; then
            need_install=true
            break
        fi
    done <"$SCRIPT_DIR/packages.txt"

    echo "$need_install"
}

run_install_base_packages() {
    # First check if we need to install anything
    if [ "$(check_packages_status)" = "false" ]; then
        success "All base packages are already installed"
        return 0
    fi

    log "Installing missing packages from packages.txt..."

    # Remove problematic repository to avoid apt update errors
    sudo rm -f /etc/apt/sources.list.d/nodesource.list

    # Update package list quietly
    sudo apt update -qq >/dev/null 2>&1

    while read -r package || [ -n "$package" ]; do
        # Skip comments and empty lines
        [[ $package =~ ^#.*$ ]] || [ -z "$package" ] && continue

        if dpkg -l | grep -q "^ii  $package "; then
            exists "$package already installed"
        else
            log "Installing $package..."
            sudo apt install -y -qq "$package" >/dev/null 2>&1 || error "Failed to install $package"
        fi
    done <"$SCRIPT_DIR/packages.txt"

    success "Base packages installation completed"
}

