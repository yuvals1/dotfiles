alias vim='nvim'
alias c='clear'
alias gtc='gt create -m'
alias cat='bat --style=plain --paging=never'
alias icat='kitty +kitten icat'
# alias y='yazi'
alias n='nvim'
# Only alias cd to z if we're in an interactive shell with zoxide available
if [[ $- == *i* ]] && command -v z &> /dev/null; then
    alias cd='z'
fi
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

alias gcalrefresh='rm -f ~/Library/Application\ Support/gcalcli/oauth && gcalcli --client-id="$GCAL_CLIENT_ID" --client-secret="$GCAL_CLIENT_SECRET" list'
alias gcalcli='gcalcli --client-id="$GCAL_CLIENT_ID" --client-secret="$GCAL_CLIENT_SECRET"'


function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    local cdfile="$(mktemp -t "yazi-cd.XXXXXX")"
    
    # Run Yazi with the CD file environment variable
    YAZI_CD_FILE="$cdfile" yazi "$@" --cwd-file="$tmp"
    
    # Check if the CD file exists and has content
    if [ -f "$cdfile" ] && [ -s "$cdfile" ]; then
        local cwd="$(cat "$cdfile")"
        if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            cd -- "$cwd"
        fi
    fi
    
    # Clean up
    rm -f -- "$tmp" "$cdfile"
}
