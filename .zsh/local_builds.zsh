# Local development builds
# These aliases point to locally built versions of tools

LAZYGIT_BIN="$HOME/dev/lazygit/lazygit"
alias lazygit="$LAZYGIT_BIN"
alias lg='lazygit --use-config-file="$HOME/.config/lazygit/config.yml"'


# Lazygit config: use SSH config with clipper when in SSH session
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    alias lazygit="$LAZYGIT_BIN --use-config-file $HOME/.config/lazygit/config.ssh.yml"
    alias lg='lazygit --use-config-file="$HOME/.config/lazygit/config.ssh.yml"'
fi



# Define yazi binary path as a variable
YAZI_BIN="$HOME/dev/yazi/target/release/yazi"
alias yazi="$YAZI_BIN"

# VisiData (local source build)
VISIDATA_ROOT="$HOME/dev/visidata"
VISIDATA_BIN="$VISIDATA_ROOT/bin/vd"
# Run VisiData from local source by default
alias vd="PYTHONPATH=$VISIDATA_ROOT $VISIDATA_BIN"
alias visidata="PYTHONPATH=$VISIDATA_ROOT $VISIDATA_BIN"
