#!/bin/bash

# First, build the base image
echo "Building base image..."
docker build -t yuvaldev-base:latest -f docker/ubuntu_x64/Dockerfile.base .

# Then, build the Neovim-ready image
echo "Building Neovim-ready image..."
docker build -t yuvaldev:latest -f docker/ubuntu_x64/Dockerfile.neovim .

echo "Done! You can now run your development environment with:"
echo "docker run -it yuvaldev:latest"
