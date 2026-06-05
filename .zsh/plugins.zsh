# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Disable zinit aliases to prevent conflicts
typeset -gx ZINIT_NO_ALIASES=1

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Explicitly define the autosuggest-accept widget
zle -N autosuggest-accept

# Add in zsh plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-syntax-highlighting

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


if [[ -n "${HOMEBREW_PREFIX:-}" && -d "$HOMEBREW_PREFIX/opt/fzf/shell" ]]; then
    fzf_shell_dir="$HOMEBREW_PREFIX/opt/fzf/shell"
elif [ -d "/opt/homebrew/opt/fzf/shell" ]; then
    fzf_shell_dir="/opt/homebrew/opt/fzf/shell"
elif [ -d "/usr/local/opt/fzf/shell" ]; then
    fzf_shell_dir="/usr/local/opt/fzf/shell"
elif [ -d "/home/linuxbrew/.linuxbrew/opt/fzf/shell" ]; then
    fzf_shell_dir="/home/linuxbrew/.linuxbrew/opt/fzf/shell"
elif [ -d "/usr/share/doc/fzf/examples" ]; then
    fzf_shell_dir="/usr/share/doc/fzf/examples"
elif [ -d "$HOME/.fzf/shell" ]; then
    fzf_shell_dir="$HOME/.fzf/shell"
fi

if [[ -n "${fzf_shell_dir:-}" ]]; then
    zinit snippet "$fzf_shell_dir/key-bindings.zsh"
    zinit snippet "$fzf_shell_dir/completion.zsh"
    unset fzf_shell_dir
fi


# Set FZF options for default behavior and history search

# Generate colors based on file extensions
export FZF_DEFAULT_COMMAND='fd --type f --hidden --no-ignore --exclude "*.mypy" --exclude "*.git" --exclude "*.mypy_cache" --color=always'
export FZF_DEFAULT_OPTS="
  --preview='bat -n --color=always {}'
  --bind shift-up:preview-page-up,shift-down:preview-page-down
--bind 'ctrl-e:execute(nvim {})'
  --ansi
"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"


export FZF_CTRL_T_OPTS="--preview='bat -n --color=always {}' --bind shift-up:preview-page-up,shift-down:preview-page-down --bind 'ctrl-y:execute-silent(echo {} | pbcopy)+abort'"

# If you need fzf-tmux, you can add an alias or function like this:
fzf-tmux() {
    if [[ -n "${HOMEBREW_PREFIX:-}" && -x "$HOMEBREW_PREFIX/opt/fzf/bin/fzf-tmux" ]]; then
        "$HOMEBREW_PREFIX/opt/fzf/bin/fzf-tmux" "$@"
    else
        command fzf-tmux "$@"
    fi
}

zinit cdreplay -q
