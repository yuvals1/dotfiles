#!/usr/bin/env bash
#
# Installs the Graphite CLI via npm.

run_install_graphite() {
    if command_exists gt; then
        local current_version
        current_version=$(gt --version)
        exists "Graphite CLI already installed: $current_version"
        return
    fi

    log "Installing Graphite CLI..."
    npm install -g @withgraphite/graphite-cli@stable || error "Failed to install Graphite CLI"

    if command_exists gt; then
        local version
        version=$(gt --version)
        success "Graphite CLI installed: $version"
    else
        error "Graphite CLI installation failed"
    fi
}

