# macOS specific settings
if [[ "$OSTYPE" == "darwin"* ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  export DYLD_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_LIBRARY_PATH"
fi

# Linux specific settings
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Common settings
if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Cargo
. "$HOME/.cargo/env"

# Load secrets file if it exists
if [ -f "$HOME/.zsh_secrets" ]; then
    source "$HOME/.zsh_secrets"
else
    echo "Warning: ~/.zsh_secrets file not found. API keys may not be set."
fi
