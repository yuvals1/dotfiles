#!/usr/bin/env zsh

#
# Frecency file writing functions
#

# Create a new frecency entry
# Args:
#   $1 - file path
#   $2 - current count (optional, defaults to 0)
# Returns:
#   Entry line in format "path count timestamp"
create_frecency_entry() {
    local file="$1"
    local count="${2:-0}"
    printf "%s\t%d\t%d\n" "$file" "$((count + 1))" "$(date +%s)"
}

# Update the frecency file with a new selection
# Args:
#   $1 - selected file path (relative to current directory)
#   $2 - path to frecency file
update_frecency_file() {
    local selected_file="$1"
    local frecency_file="$2"
    local abs_path="$(pwd)/${selected_file}"
    
    # Create temporary file with unique name
    local tmp_file="${frecency_file}.tmp.$$"
    
    # Ensure tmp file is cleaned up
    trap 'rm -f "$tmp_file"' EXIT
    
    local file_updated=0
    
    # Process existing entries
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
                    [[ "${FRECENCY_DEBUG:-0}" == "1" ]] && echo "DEBUG: Updated entry for $curr_path (count: $curr_count)"
                else
                    echo "$line" >> "$tmp_file"
                fi
            fi
        done < "$frecency_file"
    fi
    
    # Add new entry if file wasn't found
    if [[ $file_updated -eq 0 ]]; then
        create_frecency_entry "$abs_path" >> "$tmp_file"
        [[ "${FRECENCY_DEBUG:-0}" == "1" ]] && echo "DEBUG: Created new entry for $abs_path"
    fi
    
    # Atomic move
    mv "$tmp_file" "$frecency_file"
}

#
# Tests
#

test_create_frecency_entry() {
    echo "=== Testing Writer Module: Entry Creation ==="
    
    # Test basic entry creation
    local file="/test/file"
    local count=1
    local result
    result=$(create_frecency_entry "$file" "$count")
    local expected_pattern='^/test/file[[:space:]]+2[[:space:]]+[0-9]{10}$'
    
    if [[ "$result" =~ $expected_pattern ]]; then
        echo "PASS: Basic entry format"
    else
        echo "FAIL: Basic entry format"
        [[ "${FRECENCY_DEBUG:-0}" == "1" ]] && echo "Got: $result"
    fi
    
    # Test default count
    result=$(create_frecency_entry "$file")
    expected_pattern='^/test/file[[:space:]]+1[[:space:]]+[0-9]{10}$'
    
    if [[ "$result" =~ $expected_pattern ]]; then
        echo "PASS: Default count"
    else
        echo "FAIL: Default count"
        [[ "${FRECENCY_DEBUG:-0}" == "1" ]] && echo "Got: $result"
    fi
}

test_update_frecency_file() {
    echo "=== Testing Writer Module: File Updates ==="
    
    # Create test directory and files
    local test_dir
    test_dir="$(mktemp -d)"
    local test_frecency="${test_dir}/frecency.txt"
    local now
    now=$(date +%s)
    
    # Create initial test file with known entries
    printf "/test/file1\t1\t%d\n" "$now" >> "$test_frecency"
    printf "/test/file2\t2\t%d\n" "$now" >> "$test_frecency"
    
    cd "$test_dir" || exit 1
    
    # Test updating existing entry
    update_frecency_file "file1" "$test_frecency"
    if grep -q "file1.*2.*" "$test_frecency"; then
        echo "PASS: Update existing entry"
    else
        echo "FAIL: Update existing entry"
        [[ "${FRECENCY_DEBUG:-0}" == "1" ]] && cat "$test_frecency"
    fi
    
    # Test adding new entry
    update_frecency_file "newfile" "$test_frecency"
    if grep -q "newfile.*1.*" "$test_frecency"; then
        echo "PASS: Add new entry"
    else
        echo "FAIL: Add new entry"
        [[ "${FRECENCY_DEBUG:-0}" == "1" ]] && cat "$test_frecency"
    fi
    
    # Cleanup
    cd - > /dev/null || exit 1
    rm -rf "$test_dir"
}

if [[ "${FRECENCY_TEST:-0}" == "1" ]]; then
    test_create_frecency_entry
    test_update_frecency_file
fi
