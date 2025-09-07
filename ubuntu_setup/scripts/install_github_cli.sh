#!/usr/bin/env bash
#
# Installs GitHub CLI (gh) on Ubuntu via the official apt repo.

run_install_github_cli() {
    if command_exists gh; then
        exists "GitHub CLI (gh) already installed"
        # Ensure compatibility with configs that reference /usr/local/bin/gh
        local gh_path
        gh_path="$(command -v gh)"
        if [ "$gh_path" != "/usr/local/bin/gh" ]; then
            if [ -x "$gh_path" ]; then
                log "Linking $gh_path to /usr/local/bin/gh for compatibility"
                sudo ln -sf "$gh_path" /usr/local/bin/gh >/dev/null 2>&1 || true
            fi
        fi
        return 0
    fi

    log "Installing GitHub CLI (gh)..."

    # Ensure curl is available
    if ! command_exists curl; then
        sudo apt update -qq >/dev/null 2>&1 || true
        sudo apt install -y -qq curl >/dev/null 2>&1 || {
            error "Failed to install curl (required for gh repo setup)"
            return 1
        }
    fi

    # Add GitHub CLI apt repository per official instructions
    if [ ! -f /usr/share/keyrings/githubcli-archive-keyring.gpg ]; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
          | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg >/dev/null 2>&1 || true
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg >/dev/null 2>&1 || true
    fi

    if [ ! -f /etc/apt/sources.list.d/github-cli.list ]; then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
          | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    fi

    sudo apt update -qq >/dev/null 2>&1 || true
    if sudo apt install -y -qq gh >/dev/null 2>&1; then
        success "GitHub CLI installed"
    else
        error "Failed to install GitHub CLI via apt"
        return 1
    fi

    # Create a compatibility symlink for configs that reference /usr/local/bin/gh
    if command_exists gh; then
        local gh_path
        gh_path="$(command -v gh)"
        if [ -x "$gh_path" ] && [ "$gh_path" != "/usr/local/bin/gh" ]; then
            sudo ln -sf "$gh_path" /usr/local/bin/gh >/dev/null 2>&1 || true
        fi
    fi

    success "GitHub CLI (gh) is ready"
}

