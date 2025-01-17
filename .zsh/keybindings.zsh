# Emacs style key bindings
bindkey -e
# Custom keybindings
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
# bindkey '^E' autosuggest-accept   
bindkey '^D' forward-word        # Ctrl-D to accept next word while ctrl-E keep its default behavior which is accepting entire suggestion if exists and if not trying to move to end of line
bindkey '^Y' yank-line-to-clipboard
bindkey '^U' backward-kill-line
# bindkey '^G' end-of-line
bindkey "\e[3~" delete-char
