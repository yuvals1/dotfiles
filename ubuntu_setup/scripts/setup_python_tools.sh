#!/usr/bin/env bash
#
# Sets up some Python developer tools (uv, black, mypy, etc.).

run_setup_python_tools() {
    log "Setting up Python tools..."

    if ! command_exists pip; then
        log "pip is not installed, attempting to install..."
        sudo apt update && sudo apt install -y python3-pip || {
            error "Failed to install pip"
            return 1
        }
    fi

    python3 -m pip install --user --upgrade pip

    # Install uv using official installer (ensures correct architecture)
    if command_exists uv; then
        exists "uv already installed"
    else
        log "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh || error "Failed to install uv"
    fi

    # Install black
    if command_exists black; then
        exists "black already installed"
    else
        log "Installing black..."
        python3 -m pip install --user black || error "Failed to install black"
    fi

    # Install mypy
    if command_exists mypy; then
        exists "mypy already installed"
    else
        log "Installing mypy..."
        python3 -m pip install --user mypy || error "Failed to install mypy"
    fi

    success "Python tools setup completed"
}

