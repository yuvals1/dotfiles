#!/usr/bin/env bash
#
# Configures and sets up UTF-8 locales system-wide.
#
run_setup_locales() {
    log "Setting up UTF-8 locales..."

    # Generate and set locales system-wide
    sudo locale-gen "en_US.UTF-8"
    sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8

    # Set current session locale
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
    export LANGUAGE=en_US.UTF-8

    success "Locale setup completed (system-wide)"
}