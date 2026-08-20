# Local development builds
# These aliases point to locally built versions of tools

LAZYGIT_BIN="$HOME/dev/lazygit/lazygit"

# Wrapper so lazygit can cd the shell on exit (Q on a worktree, or after
# switching repos inside lazygit) via LAZYGIT_NEW_DIR_FILE
function lazygit() {
    local cdfile="$(mktemp -t "lazygit-newdir.XXXXXX")"

    LAZYGIT_NEW_DIR_FILE="$cdfile" "$LAZYGIT_BIN" "$@"
    local ret=$?

    if [ -f "$cdfile" ] && [ -s "$cdfile" ]; then
        local newdir="$(cat "$cdfile")"
        if [ -n "$newdir" ] && [ "$newdir" != "$PWD" ]; then
            cd -- "$newdir"
        fi
    fi

    rm -f -- "$cdfile"
    return $ret
}

alias lg='lazygit --use-config-file="$HOME/.config/lazygit/config.yml"'
alias l='lazygit --use-config-file="$HOME/.config/lazygit/config.yml"'

LAZYMONDAY_BIN="$HOME/dev/lazymonday/lazymonday"
alias lazymonday="$LAZYMONDAY_BIN"


# Lazygit config: use SSH config with clipper when in SSH session
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    alias lg='lazygit --use-config-file="$HOME/.config/lazygit/config.ssh.yml"'
    alias l='lazygit --use-config-file="$HOME/.config/lazygit/config.ssh.yml"'
    alias lazygit='lazygit --use-config-file="$HOME/.config/lazygit/config.ssh.yml"'
fi



# Define yazi binary path as a variable
YAZI_BIN="$HOME/dev/yazi/target/release/yazi"
function yazi() {
    local -a yazi_env
    yazi_env=(env -u NO_COLOR)
    if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
        yazi_env+=(-u DISPLAY -u WAYLAND_DISPLAY -u XAUTHORITY)
    fi
    "${yazi_env[@]}" "$YAZI_BIN" "$@"
}

# VisiData (local source build)
VISIDATA_ROOT="$HOME/dev/visidata"
VISIDATA_BIN="$VISIDATA_ROOT/bin/vd"
# Run VisiData from local source by default
alias vd="PYTHONPATH=$VISIDATA_ROOT $VISIDATA_BIN"
alias visidata="PYTHONPATH=$VISIDATA_ROOT $VISIDATA_BIN"
