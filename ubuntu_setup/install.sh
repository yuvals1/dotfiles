#!/usr/bin/env bash
#
# Main entrypoint script to run the entire system setup on Ubuntu.

# -----------------------------------------------------------------------------
# 1. Source common scripts
# -----------------------------------------------------------------------------
# We use dirname to ensure we can source relative to this file's location.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/scripts/common/colors.sh"
source "$SCRIPT_DIR/scripts/common/logger.sh"
source "$SCRIPT_DIR/scripts/common/utils.sh"

# -----------------------------------------------------------------------------
# 2. Source individual step scripts
# -----------------------------------------------------------------------------
source "$SCRIPT_DIR/scripts/setup_directories.sh"
source "$SCRIPT_DIR/scripts/install_base_packages.sh"
source "$SCRIPT_DIR/scripts/install_yazi_deps.sh"
source "$SCRIPT_DIR/scripts/setup_rust_tools.sh"
source "$SCRIPT_DIR/scripts/install_neovim.sh"
source "$SCRIPT_DIR/scripts/install_skopeo.sh"
source "$SCRIPT_DIR/scripts/install_node.sh"
source "$SCRIPT_DIR/scripts/install_npm_packages.sh"
source "$SCRIPT_DIR/scripts/install_git.sh"
source "$SCRIPT_DIR/scripts/install_zoxide.sh"
source "$SCRIPT_DIR/scripts/install_lazygit.sh"
source "$SCRIPT_DIR/scripts/install_lazydocker.sh"
source "$SCRIPT_DIR/scripts/install_btop.sh"
source "$SCRIPT_DIR/scripts/install_ncdu.sh"
source "$SCRIPT_DIR/scripts/install_ccze.sh"
source "$SCRIPT_DIR/scripts/install_bat.sh"
source "$SCRIPT_DIR/scripts/setup_fzf.sh"
source "$SCRIPT_DIR/scripts/setup_python_tools.sh"
source "$SCRIPT_DIR/scripts/setup_locales.sh"
source "$SCRIPT_DIR/scripts/install_forgit.sh"
source "$SCRIPT_DIR/scripts/install_delta.sh"

main() {
    log "Starting system setup..."

    # Adjust step order or skip steps as you like
    local steps=(
        "run_setup_directories"
        "run_install_base_packages"
        "run_install_yazi_deps"
        "run_setup_rust_tools"
        "run_install_neovim"
        "run_install_skopeo"
        "run_install_node"
        "run_install_npm_packages"
        "run_install_git"
        "run_install_zoxide"
        "run_install_lazygit"
        "run_install_lazydocker"
        "run_install_btop"
        "run_install_ncdu"
        "run_install_ccze"
        "run_install_bat"
	"run_install_forgit"
	"run_install_delta"
        "run_setup_fzf"
        "run_setup_python_tools"
        "run_setup_locales"
    )

    local total=${#steps[@]}
    local current=0

    for step in "${steps[@]}"; do
        ((current++))
        log "[$current/$total] Running ${step}..."
        # Invoke the function from each sourced script
        $step
    done

    echo ""
    success "Setup completed!"
    log "To finish setup, please run:"
    echo "    source ~/.zshrc"
    echo ""
}

main

