# Function to unset DOCKER_HOST
unset_docker_host() {
    unset DOCKER_HOST
}

# Install and setup Colima only on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
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

    # Call the setup functions
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

    # Call the function to ensure Docker is running and unset DOCKER_HOST
    ensure_docker_running
    unset_docker_host
fi
