# Ensure Cargo is installed
ensure_cargo_installed() {
    if ! command -v cargo &> /dev/null; then
        echo "Cargo not found. Installing Rust and Cargo..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
        source "$HOME/.cargo/env"
    fi

    # Add Cargo bin directory to PATH if not already present
    if [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
}

install_tree() {
    if ! command -v tree &> /dev/null; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            if command -v brew &> /dev/null; then
                echo "Installing tree using Homebrew..."
                brew install tree
            else
                echo "Homebrew not found. Please install Homebrew or tree manually."
            fi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command -v apt-get &> /dev/null; then
                echo "Installing tree using apt-get..."
                sudo apt-get update && sudo apt-get install -y tree
            else
                echo "apt-get not found. Please install tree manually."
            fi
        else
            echo "Unsupported operating system. Please install tree manually."
        fi
    fi
}

# Install bpytop using Homebrew
install_bpytop() {
    if ! command -v bpytop &> /dev/null; then
        if command -v brew &> /dev/null; then
            echo "Installing bpytop using Homebrew..."
            brew install bpytop
        else
            echo "Homebrew not found. Please install Homebrew or bpytop manually."
        fi
    fi
}


# Neovim config selector
function nvims() {
  items=("default" "scivim" "kickstart")
  config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)
  if [[ -z $config ]]; then
    echo "Nothing selected"
    return 0
  elif [[ $config == "default" ]]; then
    config=""
  fi
  NVIM_APPNAME=$config nvim $@
}

# Set clipboard command based on OS
set_clipboard_command() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        clipboard_cmd="pbcopy"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v xclip &> /dev/null; then
            clipboard_cmd="xclip -selection clipboard"
        else
            echo "xclip is not installed. Please install it using: sudo apt-get install xclip"
            return 1
        fi
    else
        echo "Unsupported operating system"
        return 1
    fi
}

# Copy directory tree to clipboard
treecopy() {
    set_clipboard_command || return 1
    local dir_name
    local tree_output
    if [ $# -eq 0 ]; then
        dir_name="current directory"
        tree_output=$(tree)
    else
        if [ -d "$1" ]; then
            dir_name="$1"
            tree_output=$(tree "$1")
        else
            echo "Error: '$1' is not a valid directory"
            return 1
        fi
    fi
    echo "$tree_output" | $clipboard_cmd
    line_count=$(echo "$tree_output" | wc -l | tr -d ' ')
    echo "ASCII tree of $dir_name copied to clipboard ($line_count lines)"
}

# Copy file content to clipboard
cpc() {
    set_clipboard_command || return 1
    if [ $# -eq 0 ]; then
        echo "Usage: cpc <filename>"
    else
        if [ -f "$1" ]; then
            content=$(cat "$1")
            echo "$content" | $clipboard_cmd
            line_count=$(echo "$content" | wc -l | tr -d ' ')
            echo "Content of '$1' copied to clipboard ($line_count lines)"
        else
            echo "Error: '$1' is not a valid file"
        fi
    fi
}

# Clipboard-related functions
yank-line-to-clipboard() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "$BUFFER" | pbcopy
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "$BUFFER" | xclip -selection clipboard
  elif [[ "$OSTYPE" == "cygwin" ]]; then
    echo "$BUFFER" > /dev/clipboard
  else
    echo "Clipboard functionality not supported on this system"
    return 1
  fi
  zle -M "Current line yanked to clipboard"
}
zle -N yank-line-to-clipboard

# rename files with hyphens to underscores
rename_hyphens_to_underscores() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: rename_hyphens_to_underscores <filename>"
        return 1
    fi

    local old_name="$1"
    local new_name="${old_name//-/_}"

    if [[ "$old_name" == "$new_name" ]]; then
        echo "No changes needed for $old_name"
        return 0
    fi

    mv -i "$old_name" "$new_name"
    echo "Renamed: $old_name -> $new_name"
}

alias rhu='rename_hyphens_to_underscores'


function yank-line-to-clipboard() {
    if [[ "$(uname)" = "Darwin" ]]; then
        # On macOS, use pbcopy directly
        echo "$BUFFER" | pbcopy
    else
        # On remote systems, use netcat to clipper
        echo "$BUFFER" | nc -N localhost 8377
    fi
    LBUFFER+=$'\n'
    zle -M "Current line yanked to clipboard"
}


# Search file contents using ripgrep and fzf
# Search file contents using ripgrep and fzf
frg() {
    local selection
    selection=$(rg --line-number --no-heading --color=always --smart-case --hidden \
        --glob '!.git/' \
        "${*:-}" |
        fzf --ansi \
            --color "hl:-1:underline,hl+:-1:underline:reverse" \
            --delimiter : \
            --preview "bat --color=always {1} --highlight-line {2}" \
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3')
    
    if [[ -n "$selection" ]]; then
        local file=$(echo "$selection" | cut -d':' -f1)
        local line=$(echo "$selection" | cut -d':' -f2)
        $EDITOR "$file" "+$line"
    fi
}

# Search in files with live preview
fif() {
    if [ ! "$#" -gt 0 ]; then
        echo "Need a string to search for!"
        return 1
    fi
    rg --files-with-matches --no-messages --hidden \
        --glob '!.git/' \
        "$1" | 
        fzf --preview "highlight -O ansi -l {} 2> /dev/null | \
            rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || \
            rg --ignore-case --pretty --context 10 '$1' {}"
}
