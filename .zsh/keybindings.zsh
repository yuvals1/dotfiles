# Emacs style key bindings
bindkey -e
# Custom keybindings
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey '^D' autosuggest-accept  # Ctrl-D to accept entire suggestion
bindkey '^E' forward-word        # Ctrl-S to accept next word
bindkey '^Y' yank-line-to-clipboard
bindkey '^U' backward-kill-line
bindkey '^G' end-of-line
