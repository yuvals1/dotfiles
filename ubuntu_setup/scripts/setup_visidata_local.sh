#!/usr/bin/env bash
#
# Sets up VisiData from local source (fork) and wires a wrapper.

run_setup_visidata_local() {
    log "Setting up local VisiData (from fork)..."

    # Ensure deps
    if ! command_exists git; then
        sudo apt update && sudo apt install -y git || error "Failed to install git"
    fi
    if ! command_exists python3; then
        sudo apt update && sudo apt install -y python3 || error "Failed to install python3"
    fi

    # Clone or update fork at ~/dev/visidata, branch 'yuval'
    local repo_dir="$HOME/dev/visidata"
    if [ ! -d "$repo_dir/.git" ]; then
        mkdir -p "$HOME/dev"
        log "Cloning fork: yuvals1/visidata -> $repo_dir"
        git clone https://github.com/yuvals1/visidata "$repo_dir" || error "Failed to clone visidata fork"
    fi

    pushd "$repo_dir" >/dev/null || error "Failed to cd into visidata repo"
    git fetch origin || true
    git checkout yuval || error "Failed to checkout branch 'yuval'"
    git pull --ff-only origin yuval || true
    popd >/dev/null

    # Install a wrapper to run local vd regardless of PYTHONPATH
    # Wrapper path
    local wrapper="/usr/local/bin/vd-local"
    local tmpfile
    tmpfile=$(mktemp)
    cat >"$tmpfile" <<WRAP
#!/usr/bin/env bash
exec env PYTHONPATH="$HOME/dev/visidata" "$HOME/dev/visidata/bin/vd" "$@"
WRAP
    sudo mv "$tmpfile" "$wrapper" || error "Failed to install vd-local wrapper"
    sudo chmod +x "$wrapper"
    success "Installed vd-local wrapper -> $wrapper"

    # Optional: if no system vd exists, link vd to the local wrapper for convenience
    if ! command_exists vd; then
        sudo ln -sf "$wrapper" /usr/local/bin/vd
        success "Linked /usr/local/bin/vd to vd-local"
    else
        exists "System 'vd' already exists; using alias/wrapper instead"
    fi

    success "Local VisiData setup complete (branch 'yuval')."
}

