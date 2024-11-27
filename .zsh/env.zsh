# macOS specific settings
if [[ "$OSTYPE" == "darwin"* ]]; then
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    echo "Homebrew not found on macOS"
  fi
  export DYLD_LIBRARY_PATH="$(brew --prefix 2>/dev/null)/lib:$DYLD_LIBRARY_PATH"
fi

# Linux specific settings
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Check architecture first before doing anything else
  ARCH=$(uname -m)
  if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm"* ]]; then
    echo "Notice: Homebrew is not supported on Linux ARM processors (${ARCH})."
    echo "Please use native package managers like 'apt' for your system."
    return 0
  fi
  if [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  else
    echo "Checking for Homebrew installation requirements..."
    # Only proceed with installation attempt on x86_64 architecture
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update
      sudo apt-get install -y build-essential procps curl file git
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      if [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        echo "Homebrew installed successfully!"
      else
        echo "Failed to install Homebrew. Please install manually."
      fi
    else
      echo "This system doesn't appear to be Ubuntu/Debian. Please install Homebrew manually."
    fi
  fi
fi
# Common settings
if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Cargo
if [ ! -f "$HOME/.cargo/env" ]; then
  echo "Cargo not found. Installing Rust and Cargo..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
  echo "Rust and Cargo have been installed."
else
  source "$HOME/.cargo/env"
fi

# Load secrets file if it exists
if [ -f "$HOME/.zsh_secrets" ]; then
    source "$HOME/.zsh_secrets"
else
    echo "Warning: ~/.zsh_secrets file not found. API keys may not be set."
fi
