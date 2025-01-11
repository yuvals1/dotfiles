#!/usr/bin/env bash
#
# Configures and sets up UTF-8 locales system-wide and in shell configs.

run_setup_locales() {
    log "Setting up UTF-8 locales..."

    # Generate and set locales
    sudo locale-gen "en_US.UTF-8"
    sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8

    # Set current session locale
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
    export LANGUAGE=en_US.UTF-8

    # Add to shell rc files
    for rc_file in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$rc_file" ]; then
            if ! grep -q "LC_ALL=en_US.UTF-8" "$rc_file"; then
                echo '' >>"$rc_file"
                echo '# Locale settings' >>"$rc_file"
                echo 'export LC_ALL=en_US.UTF-8' >>"$rc_file"
                echo 'export LANG=en_US.UTF-8' >>"$rc_file"
                echo 'export LANGUAGE=en_US.UTF-8' >>"$rc_file"
            fi
        fi
    done

    success "Locale setup completed"
}

