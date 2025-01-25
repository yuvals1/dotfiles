# Normalize a path to be relative to current directory
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

# Get score for a single file
get_file_score() {
    local file="$1"
    local -A scores
    
    eval "declare -A scores=( $2 )"
    echo "${scores[$file]:-0}"
}

# Read frecency data from file
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

# Find all files in current directory
find_files() {
    fd --type f --hidden --exclude "*.mypy" --exclude "*.git" --color=always
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

# Parse a single frecency line
parse_frecency_line() {
    local line="$1"
    local path count timestamp
    
    IFS=$'\t' read -r path count timestamp <<< "$line"
    
    if [[ -n "$path" && "$count" =~ ^[0-9]+$ && "$timestamp" =~ ^[0-9]+$ ]]; then
        printf "%s\n%d\n%d\n" "$path" "$count" "$timestamp"
    fi
}

# Create a frecency entry
create_frecency_entry() {
    local file="$1"
    local count="${2:-0}"
    printf "%s\t%d\t%d\n" "$file" "$((count + 1))" "$(date +%s)"
}

# Update frecency file
update_frecency_file() {
    local selected_file="$1"
    local frecency_file="$2"
    local abs_path
    abs_path="$(pwd)/${selected_file}"
    
    local tmp_file
    tmp_file="${frecency_file}.tmp.$$"
    
    trap 'rm -f "$tmp_file"' EXIT
    
    local file_updated=0
    
    if [[ -f "$frecency_file" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ -z "$line" ]]; then continue; fi
            
            local parsed_output
            parsed_output=$(parse_frecency_line "$line")
            
            if [[ -n "$parsed_output" ]]; then
                local curr_path curr_count curr_time
                {
                    read -r curr_path
                    read -r curr_count
                    read -r curr_time
                } <<< "$parsed_output"
                
                if [[ "$curr_path" == "$abs_path" ]]; then
                    create_frecency_entry "$curr_path" "$curr_count" >> "$tmp_file"
                    file_updated=1
                else
                    echo "$line" >> "$tmp_file"
                fi
            fi
        done < "$frecency_file"
    fi
    
    if [[ $file_updated -eq 0 ]]; then
        create_frecency_entry "$abs_path" >> "$tmp_file"
    fi
    
    mv "$tmp_file" "$frecency_file"
}

# Test functions (all remain the same)
test_normalize_path() {
    echo "Testing normalize_path..."
    cd ~/dotfiles/.zsh
    
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
    cd - > /dev/null
}

test_file_scoring() {
    echo "Testing file scoring..."
    
    local test_file="/tmp/test_frecency.txt"
    local now=$(date +%s)
    
    cat > "$test_file" << EOF
$HOME/dotfiles/.zsh/fzf_history.zsh	2	$now
$HOME/dotfiles/.zsh/aliases.zsh	1	$now
EOF
    
    cd ~/dotfiles/.zsh
    local scores_str=$(read_frecency_data "$test_file")
    echo "Scores string: $scores_str" >&2
    
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
    cd - > /dev/null
}

test_parse_frecency_line() {
    echo "Testing parse_frecency_line..."
    
    local test_line="/path/to/file	1	1234567890"
    local expected=$'/path/to/file\n1\n1234567890'
    local result
    result=$(parse_frecency_line "$test_line")
    
    if [[ "$result" == "$expected" ]]; then
        echo "PASS: Basic line parsing"
    else
        echo "FAIL: Basic line parsing"
        echo "Expected: $expected"
        echo "Got: $result"
    fi
}

test_create_frecency_entry() {
    echo "Testing create_frecency_entry..."
    
    local file="/test/file"
    local count=1
    local result
    result=$(create_frecency_entry "$file" "$count")
    local expected_pattern='^/test/file[[:space:]]+2[[:space:]]+[0-9]{10}$'
    
    if [[ "$result" =~ $expected_pattern ]]; then
        echo "PASS: Entry format"
    else
        echo "FAIL: Entry format"
        echo "Got: $result"
    fi
}

test_update_frecency_file() {
    echo "Testing update_frecency_file..."
    
    local test_dir
    test_dir="$(mktemp -d)"
    local test_frecency="${test_dir}/frecency.txt"
    local now
    now=$(date +%s)
    
    printf "/test/file1\t1\t%d\n" "$now" > "$test_frecency"
    printf "/test/file2\t2\t%d\n" "$now" >> "$test_frecency"
    
    cd "$test_dir" || exit 1
    
    update_frecency_file "file1" "$test_frecency"
    if grep -q "file1.*2.*" "$test_frecency"; then
        echo "PASS: Update existing entry"
    else
        echo "FAIL: Update existing entry"
        cat "$test_frecency"
    fi
    
    update_frecency_file "newfile" "$test_frecency"
    if grep -q "newfile.*1.*" "$test_frecency"; then
        echo "PASS: Add new entry"
    else
        echo "FAIL: Add new entry"
        cat "$test_frecency"
    fi
    
    cd - > /dev/null || exit 1
    rm -rf "$test_dir"
}

# Main function
fzf_with_history_v2() {
    local frecency_file=~/.fzf_frecency.txt
    
    if [ "${FZF_HISTORY_DEBUG:-0}" = "1" ]; then
        test_normalize_path
        test_file_scoring
        test_parse_frecency_line
        test_create_frecency_entry
        test_update_frecency_file
        return
    fi

    local scores_str
    scores_str=$(read_frecency_data "$frecency_file")
    
    local selected
    selected=$(
        find_files | \
        process_files_with_scores "$scores_str" | \
        sort -rn | \
        fzf --ansi \
            --border rounded \
            --tiebreak=index \
            --preview 'echo {} | cut -f2- | xargs bat --color=always' \
            --with-nth 2.. | \
        cut -f2-
    )
    
    if [[ -n "$selected" ]]; then
        selected=$(echo "$selected" | sed 's/\x1b\[[0-9;]*m//g')
        update_frecency_file "$selected" "$frecency_file"
        echo "$selected"
    fi
}
