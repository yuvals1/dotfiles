#!/usr/bin/env zsh

#
# File processing functions
#

# Clean ANSI color codes from text
# Args:
#   $1 - text with ANSI codes
# Returns:
#   clean text
clean_ansi_codes() {
    echo "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

# Process files and add their scores
# Args:
#   $1 - scores string in format "[file1]=score1 [file2]=score2"
# Input: list of files from stdin
# Output: tab-separated lines of "score filename"
process_files_with_scores() {
    local scores_str="$1"
    while read -r line; do
        local clean_line=$(clean_ansi_codes "$line")
        local score=$(get_file_score "$clean_line" "$scores_str")
        printf '%d\t%s\n' "$score" "$line"
    done
}

#
# Tests
#

test_clean_ansi_codes() {
    echo "Testing clean_ansi_codes..."
    
    local test_cases=(
        $'\x1b[32mtest.txt\x1b[0m:test.txt'
        $'\x1b[1;34mdir/\x1b[0mfile.txt:dir/file.txt'
        'plain.txt:plain.txt'
    )
    
    for test in "${test_cases[@]}"; do
        local input="${test%%:*}"
        local expected="${test#*:}"
        local result=$(clean_ansi_codes "$input")
        
        if [[ "$result" == "$expected" ]]; then
            echo "PASS: Clean ANSI from '$input'"
        else
            echo "FAIL: Got '$result', expected '$expected'"
        fi
    done
}

test_process_files_with_scores() {
    echo "Testing process_files_with_scores..."
    
    # Create test scores
    local scores_str="[test.txt]=100 [dir/file.txt]=200"
    
    # Create test input
    local test_input=$'test.txt\ndir/file.txt\nother.txt'
    local expected=$'100\ttest.txt\n200\tdir/file.txt\n0\tother.txt'
    
    local result=$(echo "$test_input" | process_files_with_scores "$scores_str")
    
    if [[ "$result" == "$expected" ]]; then
        echo "PASS: Files processed correctly"
    else
        echo "FAIL: Score processing"
        echo "Expected:"
        echo "$expected"
        echo "Got:"
        echo "$result"
    fi
}

if [[ "${FRECENCY_TEST:-0}" == "1" ]]; then
    test_clean_ansi_codes
    test_process_files_with_scores
fi
