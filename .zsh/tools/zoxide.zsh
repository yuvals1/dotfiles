# Initialize zoxide
if command -v zoxide >/dev/null 2>&1; then
    zoxide_bin="$(command -v zoxide)"
    if [[ "$(uname)" != "Darwin" || "$(uname -m)" != "arm64" || "$zoxide_bin" != /usr/local/* ]]; then
        eval "$("$zoxide_bin" init zsh)"
    fi
    unset zoxide_bin
fi
