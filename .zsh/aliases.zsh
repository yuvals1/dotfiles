alias vim='nvim'
alias c='clear'
alias gtc='gt create -m'
alias cat='bat --style=plain --paging=never'
alias icat='kitty +kitten icat'
alias y='yazi'
alias n='nvim'
alias cd='z'
alias sc='sesh connect $(sesh list | fzf)'
alias btop='bpytop'
alias scivim="NVIM_APPNAME=scivim nvim"
alias kickstart='NVIM_APPNAME=kickstart nvim'
alias gpr='f() { git checkout $(git rev-list -n 1 --grep="#$1" HEAD) }; f'
alias lg='lazygit --use-config-file="$HOME/.config/lazygit/config.yml"'
# Add this to your .zshrc file
alias gdcopy='git diff | pbcopy'

# Optional: alias for copying staged changes
alias gdscopy='git diff --staged | pbcopy'
