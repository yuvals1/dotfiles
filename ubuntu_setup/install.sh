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
source "$SCRIPT_DIR/scripts/install_zinit.sh"
source "$SCRIPT_DIR/scripts/install_yazi_deps.sh"
source "$SCRIPT_DIR/scripts/setup_rust_tools.sh"
source "$SCRIPT_DIR/scripts/install_neovim.sh"
source "$SCRIPT_DIR/scripts/install_skopeo.sh"
source "$SCRIPT_DIR/scripts/install_node.sh"
source "$SCRIPT_DIR/scripts/install_npm_packages.sh"
source "$SCRIPT_DIR/scripts/install_git.sh"
source "$SCRIPT_DIR/scripts/install_github_cli.sh"
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
source "$SCRIPT_DIR/scripts/install_glow.sh"
source "$SCRIPT_DIR/scripts/install_csvq.sh"
source "$SCRIPT_DIR/scripts/install_visidata.sh"
source "$SCRIPT_DIR/scripts/install_exiftool.sh"
source "$SCRIPT_DIR/scripts/install_ouch.sh"
source "$SCRIPT_DIR/scripts/install_hexyl.sh"

main() {
    log "Starting system setup..."

    # Adjust step order or skip steps as you like
    local steps=(
        "run_setup_directories"
        "run_install_base_packages"
        "run_install_zinit"
        "run_install_yazi_deps"
        "run_setup_rust_tools"
        "run_install_neovim"
        "run_install_skopeo"
        "run_install_node"
        "run_install_npm_packages"
        "run_install_git"
        "run_install_github_cli"
        "run_install_zoxide"
        "run_install_lazygit"
        "run_install_lazydocker"
        "run_install_btop"
        "run_install_ncdu"
        "run_install_ccze"
        "run_install_bat"
	"run_install_forgit"
	"run_install_delta"
	"run_install_glow"
	"run_install_csvq"
	"run_install_visidata"
	"run_install_exiftool"
	"run_install_ouch"
	"run_install_hexyl"
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
    
    # Show installation summary
    echo ""
    echo "=== Installation Summary ==="
    command -v stow >/dev/null && echo "✓ stow" || echo "✗ stow"
    command -v nvim >/dev/null && echo "✓ neovim" || echo "✗ neovim"
    command -v eza >/dev/null && echo "✓ eza" || echo "✗ eza"
    command -v yazi >/dev/null && echo "✓ yazi" || echo "✗ yazi"
    command -v ya >/dev/null && echo "✓ ya" || echo "✗ ya"
    command -v fzf >/dev/null && echo "✓ fzf" || echo "✗ fzf"
    command -v btop >/dev/null && echo "✓ btop" || echo "✗ btop"
    command -v lazygit >/dev/null && echo "✓ lazygit" || echo "✗ lazygit"
    command -v lazydocker >/dev/null && echo "✓ lazydocker" || echo "✗ lazydocker"
    command -v delta >/dev/null && echo "✓ delta" || echo "✗ delta"
    command -v glow >/dev/null && echo "✓ glow" || echo "✗ glow"
    command -v csvq >/dev/null && echo "✓ csvq" || echo "✗ csvq"
    command -v vd >/dev/null && echo "✓ visidata" || echo "✗ visidata"
    command -v exiftool >/dev/null && echo "✓ exiftool" || echo "✗ exiftool"
    command -v ouch >/dev/null && echo "✓ ouch" || echo "✗ ouch"
    command -v hexyl >/dev/null && echo "✓ hexyl" || echo "✗ hexyl"
    command -v bat >/dev/null && echo "✓ bat" || echo "✗ bat"
    command -v zoxide >/dev/null && echo "✓ zoxide" || echo "✗ zoxide"
    command -v git >/dev/null && echo "✓ git" || echo "✗ git"
    command -v node >/dev/null && echo "✓ node" || echo "✗ node"
    command -v npm >/dev/null && echo "✓ npm" || echo "✗ npm"
    command -v gh >/dev/null && echo "✓ gh" || echo "✗ gh"
    (source "$HOME/.cargo/env" 2>/dev/null && command -v rustc >/dev/null) && echo "✓ rust" || echo "✗ rust"
    [ -d ~/.forgit ] && echo "✓ forgit" || echo "✗ forgit"
    [ -d ~/.nvm ] && echo "✓ nvm" || echo "✗ nvm"
    [ -d ~/.local/share/zinit/zinit.git ] && echo "✓ zinit" || echo "✗ zinit"
    echo "==========================="
    
    log "To finish setup, please run:"
    echo "    source ~/.zshrc"
    echo ""
}

main
