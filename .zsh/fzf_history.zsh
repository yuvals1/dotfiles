fzf_with_history_v2() {
    local current_path=$(pwd)
    local frecency_file=~/.fzf_frecency.txt

    # Step 1: Just get all files using fd and pipe to fzf
    fd --type f --hidden --exclude "*.mypy" --exclude "*.git" --color=always | \
    fzf --ansi \
        --border rounded
}
