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
    git fetch origin --prune || true
    # Choose branch: prefer $LAZYGIT_BRANCH (default 'yuval') if exists on origin,
    # else use origin's default branch (master/main)
    desired_branch="${LAZYGIT_BRANCH:-yuval}"
    default_branch="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@')"
    if [ -z "$default_branch" ]; then
        default_branch="$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')"
    fi

    # Switch to desired branch when available
    if git ls-remote --exit-code --heads origin "$desired_branch" >/dev/null 2>&1; then
        git checkout -B "$desired_branch" "origin/$desired_branch" || error "Failed to checkout $desired_branch"
    elif [ -n "$default_branch" ]; then
        git checkout "$default_branch" || error "Failed to checkout $default_branch"
    fi

    # Ensure upstream and pull
    cur_branch="$(git rev-parse --abbrev-ref HEAD)"
    git branch --set-upstream-to="origin/$cur_branch" "$cur_branch" >/dev/null 2>&1 || true
    git pull --ff-only || true

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
