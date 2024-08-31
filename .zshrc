# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# Install fzf-tab
zinit ice wait'0' lucid
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey '^D' autosuggest-accept  # Ctrl-D to accept entire suggestion
bindkey '^E' forward-word        # Ctrl-S to accept next word
yank-line-to-clipboard() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "$BUFFER" | pbcopy
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "$BUFFER" | xclip -selection clipboard
  elif [[ "$OSTYPE" == "cygwin" ]]; then
    echo "$BUFFER" > /dev/clipboard
  else
    echo "Clipboard functionality not supported on this system"
    return 1
  fi
  zle -M "Current line yanked to clipboard"
}
zle -N yank-line-to-clipboard
bindkey '^Y' yank-line-to-clipboard

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Ensure Cargo is installed
ensure_cargo_installed() {
    if ! command -v cargo &> /dev/null; then
        echo "Cargo not found. Installing Rust and Cargo..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
        source "$HOME/.cargo/env"
    fi

    # Add Cargo bin directory to PATH if not already present
    if [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
}

# Install eza using Cargo
install_eza() {
    if ! command -v eza &> /dev/null; then
        echo "Installing eza using Cargo..."
        cargo install eza
    fi
}

# Set up eza aliases
setup_eza_aliases() {
    if command -v eza &> /dev/null; then
        alias ls="eza --icons=always"
        alias ll='eza -l --color=auto --icons=always'
        alias la='eza -la --color=auto --icons=always'
        alias lt='eza --tree'
    else
        echo "eza not found. Falling back to standard ls."
        alias ls='ls -G'
        alias ll='ls -lG'
        alias la='ls -laG'
    fi
}

# Install tree command using Homebrew
install_tree() {
    if ! command -v tree &> /dev/null; then
        if command -v brew &> /dev/null; then
            echo "Installing tree using Homebrew..."
            brew install tree
        else
            echo "Homebrew not found. Please install Homebrew or tree manually."
        fi
    fi
}

# Run the setup
ensure_cargo_installed
install_eza
setup_eza_aliases
install_tree

# Install and configure bat
zinit ice from"gh-r" as"command" mv"bat* -> bat" pick"bat/bat"
zinit light sharkdp/bat

# Install and load zoxide
zinit ice from"gh-r" as"command" pick"zoxide*/zoxide"
zinit light ajeetdsouza/zoxide

# Install sesh
zinit ice from"gh-r" as"command" pick"sesh"
zinit light joshmedeski/sesh

# Install yazi (modern file manager)
zinit ice from"gh-r" as"command" pick"yazi*/yazi"
zinit light sxyazi/yazi

# Install fzf
zinit ice from"gh-r" as"command" pick"fzf"
zinit light junegunn/fzf

# Install fzf-tmux script
zinit ice as"command" pick"bin/fzf-tmux"
zinit light junegunn/fzf

# Source fzf keybindings and completion
zinit snippet 'https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh'
zinit snippet 'https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh'

# Aliases
alias vim='nvim'
alias c='clear'
alias gc='gt create -m'

# Configure bat
alias cat='bat --style=plain --paging=never'

# Kitty
alias icat='kitty +kitten icat'
alias y='yazi'
alias n='nvim'
alias cd='z'
alias sc='sesh connect $(sesh list | fzf)'

. "$HOME/.cargo/env"

export DYLD_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_LIBRARY_PATH"

function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}

zle     -N             sesh-sessions
bindkey -M emacs '\es' sesh-sessions
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions

# Initialize zoxide
eval "$(zoxide init zsh)"


alias scivim="NVIM_APPNAME=scivim nvim"
alias kickstart='NVIM_APPNAME=kickstart nvim'

function nvims() {
  items=("default" "scivim" "kickstart")
  config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)
  if [[ -z $config ]]; then
    echo "Nothing selected"
    return 0
  elif [[ $config == "default" ]]; then
    config=""
  fi
  NVIM_APPNAME=$config nvim $@
}

bindkey -s ^a "nvims\n"

# Created by `pipx` on 2024-08-21 15:29:07
export PATH="$PATH:/Users/yuvals1/.local/bin"

# Load secrets file if it exists
if [ -f "$HOME/.zsh_secrets" ]; then
    source "$HOME/.zsh_secrets"
else
    echo "Warning: ~/.zsh_secrets file not found. API keys may not be set."
fi
