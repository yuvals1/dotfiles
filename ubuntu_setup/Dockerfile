FROM ubuntu:22.04

# Set non-interactive environment variables to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update and install essential tools
RUN apt-get update && apt-get install -y \
    git \
    stow \
    curl \
    wget \
    vim \
    sudo \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user (optional but recommended)
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Switch to the new user
USER $USERNAME
WORKDIR /home/$USERNAME

# Clone dotfiles repository
RUN git clone https://github.com/yuvals1/dotfiles

# Use stow to adopt dotfiles
# Note: The --adopt flag will adopt existing files
RUN cd dotfiles && stow --adopt .

# Set default command (you can override this when running the container)
CMD ["/bin/bash"]

