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

# git diff to clipboard
alias gdcopy='git diff | pbcopy'
alias gdscopy='git diff --staged | pbcopy'
gdpcopy() {
  local commits=${1:-1}
  git diff HEAD~$commits HEAD | pbcopy
  echo "Copied diff of last $commits commit(s) to clipboard"
}

# Changed files aliases
alias gfcopy='git diff --name-only | pbcopy'
alias gfscopy='git diff --staged --name-only | pbcopy'
gfpcopy() {
  local commits=${1:-1}
  git diff --name-only HEAD~$commits HEAD | pbcopy
  echo "Copied names of files changed in last $commits commit(s) to clipboard"
}
