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


if [ -d "/usr/local/opt/fzf/shell" ]; then
    # macOS Homebrew path
    zinit snippet '/usr/local/opt/fzf/shell/key-bindings.zsh'
    zinit snippet '/usr/local/opt/fzf/shell/completion.zsh'
elif [ -d "/home/linuxbrew/.linuxbrew/opt/fzf/shell" ]; then
    # Linuxbrew path
    zinit snippet '/home/linuxbrew/.linuxbrew/opt/fzf/shell/key-bindings.zsh'
    zinit snippet '/home/linuxbrew/.linuxbrew/opt/fzf/shell/completion.zsh'
elif [ -d "/usr/share/doc/fzf/examples" ]; then
    # Ubuntu apt installation path
    zinit snippet '/usr/share/doc/fzf/examples/key-bindings.zsh'
    zinit snippet '/usr/share/doc/fzf/examples/completion.zsh'
elif [ -d "$HOME/.fzf/shell" ]; then
    # Git installation path
    zinit snippet "$HOME/.fzf/shell/key-bindings.zsh"
    zinit snippet "$HOME/.fzf/shell/completion.zsh"
fi


# Set FZF options for default behavior and history search

# Generate colors based on file extensions
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude "*.mypy" --exclude "*.git" --color=always'
export FZF_DEFAULT_OPTS="
  --preview='bat -n --color=always {}'
  --bind shift-up:preview-page-up,shift-down:preview-page-down
  --ansi
"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"


export FZF_CTRL_T_OPTS="--preview='bat -n --color=always {}' --bind shift-up:preview-page-up,shift-down:preview-page-down --bind 'ctrl-y:execute-silent(echo {} | pbcopy)+abort'"

# If you need fzf-tmux, you can add an alias or function like this:
fzf-tmux() {
    /usr/local/opt/fzf/bin/fzf-tmux "$@"
}

zinit cdreplay -q


fzf_with_history() {
    local current_path=$(pwd)
    local now=$(date +%s)
    
    # Create history file if it doesn't exist
    touch ~/.fzf_history.txt
    
    # Process history with frecency scoring
    (
        if [ -f ~/.fzf_history.txt ]; then
            while IFS=$'\t' read -r file timestamp count; do
                if [[ -f "$current_path/$file" ]]; then
                    # Simple frecency score: count * (1 / age_in_days)
                    local age=$(( (now - timestamp) / 86400 + 1 ))
                    local score=$(( count * 100 / age ))
                    echo "$score	$file"
                fi
            done < ~/.fzf_history.txt | sort -nr | cut -f2
        fi
        fd --type f --hidden --exclude "*.mypy" --exclude "*.git" --color=always
    ) | sed 's|^\./||' | awk '!seen[$0]++' | \
    fzf --tiebreak=index | \
    while read -r selected; do
        # Update history with new timestamp and increment count
        local new_history=$(mktemp)
        local updated=0
        while IFS=$'\t' read -r file timestamp count || [[ -n "$file" ]]; do
            if [[ "$file" == "$selected" ]]; then
                echo -e "$file\t$now\t$((count + 1))" >> "$new_history"
                updated=1
            elif [[ -n "$file" ]]; then
                echo -e "$file\t$timestamp\t$count" >> "$new_history"
            fi
        done < ~/.fzf_history.txt
        if [[ $updated -eq 0 ]]; then
            echo -e "$selected\t$now\t1" >> "$new_history"
        fi
        mv "$new_history" ~/.fzf_history.txt
        echo "$selected"
    done
}
