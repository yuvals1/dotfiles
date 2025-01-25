#!/usr/bin/env zsh

#
# Frecency file parsing functions
#

# Parse a single line from frecency file
# Args:
#   $1 - line in format "path count timestamp"
# Returns:
#   Multi-line string: "path\ncount\ntimestamp" or empty if invalid
parse_frecency_line() {
    local line="$1"
    local path count timestamp
    
    # Use read to split on tabs
    IFS=$'\t' read -r path count timestamp <<< "$line"
    
    # Validate all components exist and are in correct format
    if [[ -n "$path" && "$count" =~ ^[0-9]+$ && "$timestamp" =~ ^[0-9]+$ ]]; then
        printf "%s\n%d\n%d\n" "$path" "$count" "$timestamp"
    fi
}

#
# Tests
#

test_parse_frecency_line() {
    echo "=== Testing Parser Module ==="
    
    # Test valid input
    local test_cases=(
        # Format: "input:expected_path:expected_count:expected_timestamp"
        "/path/to/file	1	1234567890:/path/to/file:1:1234567890"
        "~/file.txt	42	1000000000:~/file.txt:42:1000000000"
    )
    
    for test in "${test_cases[@]}"; do
        local input="${test%%:*}"
        local rest="${test#*:}"
        local expected_path="${rest%%:*}"; rest="${rest#*:}"
        local expected_count="${rest%%:*}"; rest="${rest#*:}"
        local expected_timestamp="$rest"
        
        local result=$(parse_frecency_line "$input")
        local expected="${expected_path}\n${expected_count}\n${expected_timestamp}"
        
        if [[ "$result" == "$expected" ]]; then
            echo "PASS: Basic line parsing '$input'"
        else
            if [[ "${FRECENCY_DEBUG:-0}" == "1" ]]; then
                echo "Expected:"
                echo "$expected" | xxd
                echo "Got:"
                echo "$result" | xxd
            fi
            echo "FAIL: Basic line parsing '$input'"
        fi
    done
    
    # Test invalid inputs
    local invalid_cases=(
        ""
        "invalid"
        "path	not_number	1234567890"
        "path	1	not_number"
        "path		1234567890"
    )
    
    for input in "${invalid_cases[@]}"; do
        local result=$(parse_frecency_line "$input")
        if [[ -z "$result" ]]; then
            echo "PASS: Invalid input handled correctly: '$input'"
        else
            echo "FAIL: Invalid input should return empty: '$input'"
            if [[ "${FRECENCY_DEBUG:-0}" == "1" ]]; then
                echo "Got: $result"
            fi
        fi
    done
}

if [[ "${FRECENCY_TEST:-0}" == "1" ]]; then
    test_parse_frecency_line
fi
