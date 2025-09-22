#!/usr/bin/env bash
#
# Sets up Lazygit from local source (fork).
#
run_setup_lazygit_local() {
    log "Setting up local Lazygit (from fork)..."

    # Clone or update fork at ~/dev/lazygit, branch 'yuval'
    local repo_dir="$HOME/dev/lazygit"
    if [ ! -d "$repo_dir/.git" ]; then
        mkdir -p "$HOME/dev"
        log "Cloning fork: yuvals1/lazygit -> $repo_dir"
        git clone https://github.com/yuvals1/lazygit "$repo_dir" || error "Failed to clone lazygit fork"
    fi

    pushd "$repo_dir" >/dev/null || error "Failed to cd into lazygit repo"
    git fetch origin || true
    git checkout yuval || error "Failed to checkout branch 'yuval'"
    git pull --ff-only origin yuval || true

    # Build local binary
    log "Building lazygit..."
    go build -o lazygit || error "go build failed"

    # Install binary directly
    sudo cp lazygit /usr/local/bin/lazygit || error "Failed to install lazygit"
    sudo chmod +x /usr/local/bin/lazygit

    popd >/dev/null

    success "Local Lazygit setup complete (branch 'yuval')."
}