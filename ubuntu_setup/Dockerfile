FROM ubuntu:22.04

# Avoid interactive prompts during package install
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal dependencies so your script can run
RUN apt-get update -qq && apt-get install -y \
    git curl wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy your ubuntu_setup/ folder into the container
COPY . /ubuntu_setup

WORKDIR /ubuntu_setup

# Make install.sh executable
RUN chmod +x ./install.sh

# By default, just run the installation
CMD ["./install.sh"]

