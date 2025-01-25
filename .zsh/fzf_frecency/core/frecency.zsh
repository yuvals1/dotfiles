#!/usr/bin/env zsh

#
# Core frecency scoring functions
#

# Get score for a single file
# Args:
#   $1 - file path
#   $2 - scores string in format "[file1]=score1 [file2]=score2"
# Returns:
#   score of the file or 0 if not found
get_file_score() {
    local file="$1"
    local -A scores
    
    eval "declare -A scores=( $2 )"
    echo "${scores[$file]:-0}"
}

# Read and parse frecency data from file
# Args:
#   $1 - path to frecency file
# Returns:
#   scores string in format "[file1]=score1 [file2]=score2"
read_frecency_data() {
    local frecency_file="$1"
    local result=""
    
    if [[ -f "$frecency_file" ]]; then
        while IFS=$'\t' read -r file count last_access; do
            if [[ -z "$file" ]]; then continue; fi
            local days_since=$(((`date +%s` - last_access) / 86400 + 1))
            local normalized_path=$(normalize_path "$file")
            local score=$(( count * 100 / days_since ))
            result+="[$normalized_path]=$score "
        done < "$frecency_file"
    fi
    echo "$result"
}

#
# Tests
#

test_file_scoring() {
    echo "Testing file scoring..."
    
    local test_file="/tmp/test_frecency.txt"
    local now=$(date +%s)
    
    # Create test file with known scores
    cat > "$test_file" << EOF
$HOME/dotfiles/.zsh/fzf_history.zsh	2	$now
$HOME/dotfiles/.zsh/aliases.zsh	1	$now
EOF
    
    local scores_str=$(read_frecency_data "$test_file")
    echo "Scores string: $scores_str" >&2
    
    # Test cases with expected scores
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
    
    rm -f "$test_file"
}

if [[ "${FRECENCY_TEST:-0}" == "1" ]]; then
    test_file_scoring
fi
