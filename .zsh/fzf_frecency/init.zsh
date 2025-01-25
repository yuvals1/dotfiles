#!/usr/bin/env zsh

#
# FZF with frecency initialization
#

# Get the directory containing this script
SCRIPT_DIR="${0:A:h}"

# Source all required files in dependency order
source "${SCRIPT_DIR}/core/file_handling.zsh"
source "${SCRIPT_DIR}/core/frecency.zsh"
source "${SCRIPT_DIR}/core/file_processing.zsh"
source "${SCRIPT_DIR}/storage/parser.zsh"
source "${SCRIPT_DIR}/storage/writer.zsh"

# Run all tests
run_frecency_tests() {
    local current_dir="$(pwd)"
    echo "Running all frecency tests..."
    echo "=========================="
    
    FRECENCY_TEST=1 source "${SCRIPT_DIR}/core/file_handling.zsh"
    FRECENCY_TEST=1 source "${SCRIPT_DIR}/core/frecency.zsh"
    FRECENCY_TEST=1 source "${SCRIPT_DIR}/core/file_processing.zsh"
    FRECENCY_TEST=1 source "${SCRIPT_DIR}/storage/parser.zsh"
    FRECENCY_TEST=1 source "${SCRIPT_DIR}/storage/writer.zsh"
    
    cd "$current_dir"
}

# Main function for fuzzy finding files with frecency
fzf_with_frecency() {
    local frecency_file=~/.fzf_frecency.txt
    
    # Run tests if in debug mode
    if [ "${FRECENCY_DEBUG:-0}" = "1" ]; then
        run_frecency_tests
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
    
    # Update frecency data if a file was selected
    if [[ -n "$selected" ]]; then
        selected=$(clean_ansi_codes "$selected")
        update_frecency_file "$selected" "$frecency_file"
        echo "$selected"
    fi
}

# Hook for zsh completion
_fzf_with_frecency() {
    _arguments \
        '--debug[Run all tests]'
}
