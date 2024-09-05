# Emacs style key bindings
bindkey -e

# Custom keybindings
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey '^D' autosuggest-accept  # Ctrl-D to accept entire suggestion
bindkey '^E' forward-word        # Ctrl-S to accept next word
bindkey '^Y' yank-line-to-clipboard
bindkey -s ^a "nvims\n"

# Sesh keybinding
zle -N sesh-sessions
bindkey -M emacs '\es' sesh-sessions
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions
