# Install and setup Colima only on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
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
else
    # For non-macOS systems (like Ubuntu)
    ensure_docker_running() {
        if command -v systemctl &> /dev/null; then
            if ! systemctl is-active --quiet docker; then
                echo "Starting Docker..."
                sudo systemctl start docker
            fi
        else
            echo "Docker service management not supported on this system."
        fi
    }

    # Call the function to ensure Docker is running
    ensure_docker_running
fi
