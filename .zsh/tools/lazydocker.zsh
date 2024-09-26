# Setup lazydocker alias
setup_lazydocker_alias() {
    if command -v lazydocker &> /dev/null; then
        alias lzd='lazydocker'
    else
        echo "lazydocker not found. Alias not set."
    fi
}

# Call the setup function
setup_lazydocker_alias
