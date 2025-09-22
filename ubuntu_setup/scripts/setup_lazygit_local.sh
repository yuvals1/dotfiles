#!/usr/bin/env bash
#
# Sets up Lazygit from local source and wires a wrapper.

run_setup_lazygit_local() {
    log "Setting up local Lazygit (from source)..."

    # Ensure deps
    if ! command_exists git; then
        sudo apt update && sudo apt install -y git || error "Failed to install git"
    fi
    if ! command_exists go; then
        # Install Go (simple snap/apt option). Prefer apt from Ubuntu repos.
        sudo apt update && sudo apt install -y golang || error "Failed to install golang"
    fi

    # Clone or update at ~/dev/lazygit
    local repo_dir="$HOME/dev/lazygit"
    if [ ! -d "$repo_dir/.git" ]; then
        mkdir -p "$HOME/dev"
        log "Cloning jesseduffield/lazygit -> $repo_dir"
        git clone https://github.com/jesseduffield/lazygit "$repo_dir" || error "Failed to clone lazygit"
    fi

    pushd "$repo_dir" >/dev/null || error "Failed to cd into lazygit repo"
    git fetch origin || true
    # Keep current branch if you have local changes; otherwise track master
    if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
        git checkout master || true
        git pull --ff-only origin master || true
    else
        git pull --ff-only || true
    fi

    # Build local binary
    log "Building lazygit..."
    go build -o lazygit || error "go build failed"
    popd >/dev/null

    # Install a wrapper to run local lazygit
    local wrapper="/usr/local/bin/lazygit-local"
    local tmpfile
    tmpfile=$(mktemp)
    cat >"$tmpfile" <<'WRAP'
#!/usr/bin/env bash
exec "$HOME/dev/lazygit/lazygit" "$@"
WRAP
    sudo mv "$tmpfile" "$wrapper" || error "Failed to install lazygit-local wrapper"
    sudo chmod +x "$wrapper"
    success "Installed lazygit-local wrapper -> $wrapper"

    # Optional: if no system lazygit exists, link lazygit to the local wrapper
    if ! command_exists lazygit; then
        sudo ln -sf "$wrapper" /usr/local/bin/lazygit
        success "Linked /usr/local/bin/lazygit to lazygit-local"
    else
        exists "System 'lazygit' already exists; using alias/wrapper instead"
    fi

    success "Local Lazygit setup complete."
}
