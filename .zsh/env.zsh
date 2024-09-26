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
  if [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  else
    echo "Homebrew not found on Linux"
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
