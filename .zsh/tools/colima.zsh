# Install Colima
install_colima() {
    if ! command -v colima &> /dev/null; then
        if command -v brew &> /dev/null; then
            echo "Installing Colima using Homebrew..."
            brew install colima
        else
            echo "Homebrew not found. Please install Homebrew or Colima manually."
        fi
    fi
}

# Ensure Colima is running
ensure_colima_running() {
    if ! colima status &>/dev/null; then
        echo "Starting Colima..."
        colima start
    fi
}

# Setup Colima environment
setup_colima_env() {
    export DOCKER_HOST="unix://${HOME}/.colima/docker.sock"
}

# Call the installation and setup functions
install_colima
ensure_colima_running
setup_colima_env
