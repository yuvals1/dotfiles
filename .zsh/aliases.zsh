alias vim='nvim'
alias c='clear'
alias gtc='gt create -m'
alias cat='bat --style=plain --paging=never'
alias icat='kitty +kitten icat'
alias y='yazi'
alias n='nvim'
alias cd='z'
alias scivim="NVIM_APPNAME=scivim nvim"
alias kickstart='NVIM_APPNAME=kickstart nvim'
alias gpr='f() { git checkout $(git rev-list -n 1 --grep="#$1" HEAD) }; f'
alias lg='lazygit --use-config-file="$HOME/.config/lazygit/config.yml"'
alias tt="taskwarrior-tui"
alias lsq="lazysql"
alias lzd="lazydocker"
alias th="tv files-with-hidden"
alias glt="python3 ~/dotfiles/scripts/time-calc.py"
alias zi="zoxide query -i"
# [[ -f ~/dev/lazygit/lazygit ]] && alias lazygit="~/dev/lazygit/lazygit"
alias gdn='git diff --name-only'
alias l='~/links.sh'
alias s='pbpaste | say'
alias s1='pbpaste | say -r 150'
alias s2='pbpaste | say -r 180'
alias s3='pbpaste | say -r 200'

