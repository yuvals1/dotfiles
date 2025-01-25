# Previous normalize_path and find_files functions remain the same...
normalize_path() {
    local path="$1"
    local current_dir="$(pwd)"
    
    if [[ "$path" = "$current_dir/"* ]]; then
        path="${path#$current_dir/}"
    elif [[ "$path" = "$HOME/"* ]]; then
        local rel_path="${path#$HOME/}"
        local home_to_current="${current_dir#$HOME/}"
        if [[ "$current_dir" = "$HOME/"* ]]; then
            path="${rel_path#$home_to_current/}"
        else
            path="$rel_path"
        fi
    fi
    
    path="${path/#.\//}"
    echo "$path"
}

find_files() {
    fd --type f --hidden --exclude "*.mypy" --exclude "*.git" --color=always
}

# Score a single file based on frecency data
get_file_score() {
    local file="$1"
    local -A scores
    
    # Parse scores string into associative array
    eval "declare -A scores=( $2 )"
    
    # Return score or 0 if not found
    echo "${scores[$file]:-0}"
}

# Process files with scores
process_files_with_scores() {
    local scores_str="$1"
    while read -r line; do
        local clean_line=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g')
        local score=$(get_file_score "$clean_line" "$scores_str")
        printf '%d\t%s\n' "$score" "$line"
    done
}

# Read frecency data from file
read_frecency_data() {
    local frecency_file="$1"
    local result=""
    
    if [[ -f "$frecency_file" ]]; then
        while IFS=$'\t' read -r file count last_access; do
            local days_since=$(((`date +%s` - last_access) / 86400 + 1))
            local normalized_path=$(normalize_path "$file")
            local score=$(( count * 100 / days_since ))
            # Format for associative array declaration
            result+="[$normalized_path]=$score "
        done < "$frecency_file"
    fi
    echo "$result"
}

# Test file scoring
test_file_scoring() {
    local test_file="/tmp/test_frecency.txt"
    local now=$(date +%s)
    
    # Create test frecency file
    cat > "$test_file" << EOF
$HOME/dotfiles/.zsh/fzf_history.zsh	2	$now
$HOME/dotfiles/.zsh/aliases.zsh	1	$now
EOF
    
    echo "Testing file scoring..."
    cd ~/dotfiles/.zsh  # Set up test environment
    
    # Read frecency data
    local scores_str=$(read_frecency_data "$test_file")
    echo "Scores string: $scores_str" >&2
    
    # Test a few files
    local test_files=(
        "fzf_history.zsh:200"
        "aliases.zsh:100"
        "nonexistent.zsh:0"
    )
    
    for test in "${test_files[@]}"; do
        local file="${test%%:*}"
        local expected="${test#*:}"
        local score=$(get_file_score "$file" "$scores_str")
        if [ "$score" = "$expected" ]; then
            echo "PASS: $file scored $score"
        else
            echo "FAIL: $file scored $score, expected $expected"
        fi
    done
    
    rm "$test_file"
    cd - > /dev/null
}

# Main function
fzf_with_history_v2() {
    local frecency_file=~/.fzf_frecency.txt
    
    # Run tests in debug mode
    if [ "${FZF_HISTORY_DEBUG:-0}" = "1" ]; then
        test_normalize_path
        test_file_scoring
        return
    fi

    # Read frecency data
    local scores_str=$(read_frecency_data "$frecency_file")
    
    # Find files and process them with scores
    find_files | \
    process_files_with_scores "$scores_str" | \
    sort -rn | \
    fzf --ansi \
        --border rounded \
        --preview 'echo {} | cut -f2- | xargs bat --color=always' \
        --with-nth 2.. # Hide the score column
}
