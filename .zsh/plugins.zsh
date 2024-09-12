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

# Set FZF options for default behavior and history search
export FZF_CTRL_T_OPTS="--preview='bat -n --color=always {}' --bind shift-up:preview-page-up,shift-down:preview-page-down   --bind 'ctrl-y:execute-silent(echo {} | pbcopy)+abort'"
export FZF_CTRL_R_OPTS="--reverse"

# Source fzf keybindings and completion
zinit snippet 'https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh'
zinit snippet 'https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh'

zinit cdreplay -q
