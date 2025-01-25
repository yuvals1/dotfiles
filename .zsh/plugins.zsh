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
    local frecency_file=~/.fzf_frecency.txt
    local separator=$'\e[0;34m'"━━━━━━━━━━━━━━━━━━━━━━━━━━━━"$'\e[0m'

    # Create or load frecency data
    declare -A frecency_scores
    if [ -f "$frecency_file" ]; then
        while IFS=$'\t' read -r file count last_access; do
            local days_since=$(((`date +%s` - last_access) / 86400 + 1))
            frecency_scores[$file]=$(( count * 100 / days_since ))
        done < "$frecency_file"
    fi

    (
        # Output frecency-sorted files first
        if [ -f "$frecency_file" ]; then
            {
                while IFS=$'\t' read -r line _ _; do
                    if [[ -f "$current_path/$line" ]]; then
                        local score=${frecency_scores[$line]:-0}
                        local dir=$(dirname "$line")
                        local file=$(basename "$line")
                        
                        local colored_dir=""
                        if [ "$dir" != "." ]; then
                            colored_dir="\033[34m${dir}/\033[0m"
                        fi
                        
                        local colored_line=""
                        if [[ "$file" =~ \.(cpp|h|hpp)$ ]]; then
                            colored_line="${colored_dir}\033[35m${file}\033[0m"
                        elif [[ "$file" =~ \.(py)$ ]]; then
                            colored_line="${colored_dir}\033[32m${file}\033[0m"
                        elif [[ "$file" =~ \.(js|ts)$ ]]; then
                            colored_line="${colored_dir}\033[33m${file}\033[0m"
                        else
                            colored_line="${colored_dir}\033[36m${file}\033[0m"
                        fi
                        echo "$score $line $colored_line"
                    fi
                done < "$frecency_file" | sort -rn | cut -d' ' -f3-
            }
        fi
        
        echo "$separator"
        
        # Then add fd results
        fd --type f --hidden --exclude "*.mypy" --exclude "*.git" --color=always
    ) | sed 's|^\./||' | \
    awk -v sep="$separator" '{ 
        cleaned=$0
        gsub(/\033\[[0-9;]*m/, "", cleaned)
        if (cleaned == sep) {
            print cleaned
        } else if (!seen[cleaned]++) {
            print $0
        }
    }' | \
    fzf --tiebreak=index --ansi \
        # --height ~50% \
        --border rounded \
        --header "$separator" | tee >(
        while read -r selected; do
            clean_selected=$(echo "$selected" | sed 's/\x1b\[[0-9;]*m//g')
            timestamp=$(date +%s)
            
            touch "$frecency_file.tmp"
            if [ -f "$frecency_file" ]; then
                while IFS=$'\t' read -r file count last_access; do
                    if [ "$file" = "$clean_selected" ]; then
                        echo -e "$file\t$((count + 1))\t$timestamp" >> "$frecency_file.tmp"
                    else
                        echo -e "$file\t$count\t$last_access" >> "$frecency_file.tmp"
                    fi
                done < "$frecency_file"
            fi
            
            if ! grep -q "^$clean_selected	" "$frecency_file.tmp" 2>/dev/null; then
                echo -e "$clean_selected\t1\t$timestamp" >> "$frecency_file.tmp"
            fi
            
            mv "$frecency_file.tmp" "$frecency_file"
        done
    )
}
