#!/usr/bin/env bash
#
# Installs the latest Git from the git-core PPA if needed.

run_install_git() {
    if command_exists git; then
        local current_version
        current_version=$(git --version | awk '{print $3}')
        # Compare versions to ensure we have at least 2.38
        if [ "$(printf '%s\n' "2.38" "$current_version" | sort -V | head -n1)" = "2.38" ]; then
            exists "Git version $current_version is already installed and meets requirements"
            return 0
        fi
    fi

    log "Installing Git from PPA..."
    sudo add-apt-repository -y ppa:git-core/ppa >/dev/null 2>&1
    sudo apt update -qq >/dev/null 2>&1
    sudo apt install -y -qq git >/dev/null 2>&1

    local new_version
    new_version=$(git --version | awk '{print $3}')
    success "Git $new_version installed successfully"
}

