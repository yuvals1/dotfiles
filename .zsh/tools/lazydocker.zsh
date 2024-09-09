# Install lazydocker
install_lazydocker() {
    if ! command -v lazydocker &> /dev/null; then
        if command -v brew &> /dev/null; then
            echo "Installing lazydocker using Homebrew..."
            brew install jesseduffield/lazydocker/lazydocker
        else
            echo "Homebrew not found. Please install Homebrew or lazydocker manually."
        fi
    fi
}

# Setup lazydocker alias
setup_lazydocker_alias() {
    if command -v lazydocker &> /dev/null; then
        alias lzd='lazydocker'
    else
        echo "lazydocker not found. Alias not set."
    fi
}

# Call the installation and setup functions
install_lazydocker
setup_lazydocker_alias
