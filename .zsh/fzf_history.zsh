fzf_with_history_v2() {
    local current_path=$(pwd)
    local frecency_file=~/.fzf_frecency.txt

    # Read and parse frecency data into associative array
    declare -A frecency_scores
    if [ -f "$frecency_file" ]; then
        echo "Reading frecency file..." >&2  # Debug output
        while IFS=$'\t' read -r file count last_access; do
            local days_since=$(((`date +%s` - last_access) / 86400 + 1))
            frecency_scores[$file]=$(( count * 100 / days_since ))
            echo "File: $file, Score: ${frecency_scores[$file]}" >&2  # Debug output
        done < "$frecency_file"
    fi

    # Just get all files using fd and pipe to fzf (same as step 1)
    fd --type f --hidden --exclude "*.mypy" --exclude "*.git" --color=always | \
    fzf --ansi \
        --border rounded
}
