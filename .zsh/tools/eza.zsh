# Install eza
install_eza() {
    if ! command -v eza &> /dev/null; then
        echo "Installing eza using Cargo..."
        cargo install eza
    fi
}

# Setup eza aliases
setup_eza_aliases() {
    if command -v eza &> /dev/null; then
        alias ls="eza --icons=always"
        alias ll='eza -l --color=auto --icons=always'
        alias la='eza -la --color=auto --icons=always'
        alias lt='eza --tree'
    else
        echo "eza not found. Falling back to standard ls."
        alias ls='ls -G'
        alias ll='ls -lG'
        alias la='ls -laG'
    fi
}

# Call the installation and setup functions
install_eza
setup_eza_aliases
