# Local development builds
# These aliases point to locally built versions of tools

LAZYGIT_BIN="$HOME/dev/lazygit/lazygit"
alias lazygit="$LAZYGIT_BIN"

# Define yazi binary path as a variable
YAZI_BIN="$HOME/dev/yazi/target/release/yazi"
alias yazi="$YAZI_BIN"

# VisiData (local source build)
VISIDATA_ROOT="$HOME/dev/visidata"
VISIDATA_BIN="$VISIDATA_ROOT/bin/vd"
# Run VisiData from local source by default
alias vd="PYTHONPATH=$VISIDATA_ROOT $VISIDATA_BIN"
alias visidata="PYTHONPATH=$VISIDATA_ROOT $VISIDATA_BIN"
