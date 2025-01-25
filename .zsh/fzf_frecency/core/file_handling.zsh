#!/usr/bin/env zsh

#
# Core file handling functions
#

# Normalize a path to be relative to current directory
# Args:
#   $1 - path to normalize
# Returns:
#   normalized path relative to current directory
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

# Find all files in current directory
# Returns:
#   list of files with colors
find_files() {
    fd --type f --hidden --exclude "*.mypy" --exclude "*.git" --color=always
}

#
# Tests
#

test_normalize_path() {
    echo "Testing normalize_path..."
    local current_dir="$(pwd)"
    
    local test_cases=(
        "$HOME/dotfiles/.zsh/fzf_history.zsh:fzf_history.zsh"
        "$HOME/dotfiles/.zsh/dir/file.txt:dir/file.txt"
        "./file.txt:file.txt"
        "dir/file.txt:dir/file.txt"
        "../other/file.txt:../other/file.txt"
    )
    
    for test in "${test_cases[@]}"; do
        local input="${test%%:*}"
        local expected="${test#*:}"
        local result="$(normalize_path "$input")"
        
        if [ "$result" = "$expected" ]; then
            echo "PASS: $input -> $result"
        else
            echo "FAIL: $input -> $result (expected $expected)"
        fi
    done
}

if [[ "${FRECENCY_TEST:-0}" == "1" ]]; then
    test_normalize_path
fi
