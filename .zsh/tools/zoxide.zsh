# Clean up any existing zoxide-related items
unalias z zi cd 2>/dev/null
unfunction z zi _zoxide_hook 2>/dev/null

# Initialize zoxide
eval "$(zoxide init zsh)"

alias cd=z
