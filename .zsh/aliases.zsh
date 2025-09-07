alias vim='nvim'
alias c='clear'
alias cat='bat --style=plain --paging=never'
alias icat='kitty +kitten icat'
alias n='nvim'
alias scivim="NVIM_APPNAME=scivim nvim"
alias kickstart='NVIM_APPNAME=kickstart nvim'
alias gpr='f() { git checkout $(git rev-list -n 1 --grep="#$1" HEAD) }; f'

alias lg='lazygit --use-config-file="$HOME/.config/lazygit/config.yml"'
alias lsq="lazysql"
alias lzd="lazydocker"
alias find="fd"
alias th="tv files-with-hidden"
alias glt="python3 ~/dotfiles/scripts/time-calc.py"
alias zqi="zoxide query -i"
# [[ -f ~/dev/lazygit/lazygit ]] && alias lazygit="~/dev/lazygit/lazygit"
alias gdn='git diff --name-only'
alias s='pbpaste | say'
alias s1='pbpaste | say -r 150'
alias s2='pbpaste | say -r 180'
alias s3='pbpaste | say -r 200'

alias gcalrefresh='rm -f ~/Library/Application\ Support/gcalcli/oauth && gcalcli --client-id="$GCAL_CLIENT_ID" --client-secret="$GCAL_CLIENT_SECRET" list'
alias gcalcli='gcalcli --client-id="$GCAL_CLIENT_ID" --client-secret="$GCAL_CLIENT_SECRET"'


alias pomo="$HOME/dotfiles/.config/sketchybar/pomo"
alias pomo-vis="$HOME/dotfiles/.config/sketchybar/pomo-vis"
alias pv="pomo-vis"
alias spotify-restart="$HOME/dotfiles/.config/sketchybar/plugins/spotify_daemon_restart.sh restart"
alias spotify-fix="$HOME/dotfiles/.config/sketchybar/plugins/spotify_fix_all.sh"

# Notification command
alias notify="$HOME/dotfiles/tools/notify-wrapper.sh"
alias noti="notify"

# Fix mpv segfault caused by FZF_DEFAULT_OPTS
alias mpv='env -u FZF_DEFAULT_OPTS mpv'

alias tl='cd ~/commitments/ && y'


function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    local cdfile="$(mktemp -t "yazi-cd.XXXXXX")"
    
    # Run Yazi with the CD file environment variable
    YAZI_CD_FILE="$cdfile" "$YAZI_BIN" "$@" --cwd-file="$tmp"
    
    # Check if the CD file exists and has content
    if [ -f "$cdfile" ] && [ -s "$cdfile" ]; then
        local cwd="$(cat "$cdfile")"
        if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            cd -- "$cwd"
        fi
    fi
    
    # Clean up
    rm -f -- "$tmp" "$cdfile"
}

alias yt='y ~/personal/tasks/"$TASK_PROGRESS"'
alias yp='y ~/personal'
alias yc='y ~/personal/calendar/days/'
alias yd='y ~/dotfiles'


alias codex-history-list='node "$HOME/dev/codex-history-list/dist/cli.js"'
# BEGIN codex-history-pick
codex-history-pick() {
  # Dependencies
  for cmd in codex-history-list jq fzf; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "Missing dependency: $cmd" >&2
      return 1
    fi
  done

  # Build the list and let fzf return the full selected TSV row
  local sel
  sel=$(codex-history-list --json "$@" \
    | jq -r '.[] | [(((.mtime/1000|floor)|strflocaltime("%Y-%m-%d %H:%M"))), (.cwd // "-"), (.ask // "-"), .path] | @tsv' \
    | fzf --delimiter $'\t' \
          --with-nth=1,2,3 \
          --preview 'echo {4}' \
          --preview-window=down,3,wrap \
          --prompt='codex> ')
  [ -n "$sel" ] || return 1

  # Extract path (last TSV field)
  local path
  path="${sel##*$'\t'}"
  if [ -z "$path" ] || [ "$path" = "$sel" ]; then
    echo "No path selected" >&2
    return 1
  fi

  # Resolve codex binary robustly (env override, PATH, which, npm, toolchains)
  local codexBin=""
  # 1) Honor explicit override
  if [ -n "$CODEX_BIN" ] && [ -x "$CODEX_BIN" ]; then
    codexBin="$CODEX_BIN"
  fi
  # 2) PATH discovery
  if [ -z "$codexBin" ]; then
    codexBin="$(command -v codex 2>/dev/null || true)"
  fi
  # 3) whence as extra safety on zsh (avoid external coreutils like head)
  if [ -z "$codexBin" ]; then
    codexBin="$(whence -p codex 2>/dev/null || true)"
  fi
  # 4) NVM-provided bin
  if [ -z "$codexBin" ] && [ -n "$NVM_BIN" ] && [ -x "$NVM_BIN/codex" ]; then
    codexBin="$NVM_BIN/codex"
  fi
  # 5) npm global bin directory
  if [ -z "$codexBin" ]; then
    local npmBin
    npmBin="$(npm bin -g 2>/dev/null || true)"
    if [ -n "$npmBin" ] && [ -x "$npmBin/codex" ]; then
      codexBin="$npmBin/codex"
    fi
  fi
  # 6) Common install locations (NVM, Volta, asdf, system)
  if [ -z "$codexBin" ]; then
    for candidate in \
      "$HOME/.nvm/versions/node/current/bin/codex" \
      "$HOME/.nvm/versions/node"/*/bin/codex \
      "$HOME/.volta/bin/codex" \
      "$HOME/.asdf/shims/codex" \
      "$HOME/.local/bin/codex" \
      "/opt/homebrew/bin/codex" \
      "/usr/local/bin/codex" \
      "/usr/bin/codex"; do
      if [ -x "$candidate" ]; then
        codexBin="$candidate"
        break
      fi
    done
  fi

  if [ -z "$codexBin" ] || [ ! -x "$codexBin" ]; then
    echo "codex CLI not found." >&2
    echo "Tried: CODEX_BIN, PATH, which, npm -g bin, NVM/Volta/asdf, common system paths." >&2
    echo "Hint: export CODEX_BIN=\"$HOME/.nvm/versions/node/v20.19.5/bin/codex\"" >&2
    return 1
  fi

  echo "Launching Codex for: $path"
  # Ensure Node is discoverable by codex's shebang. Prefer NVM/bin and the codex bin dir.
  local launchPath="$PATH"
  [ -n "$NVM_BIN" ] && launchPath="$NVM_BIN:$launchPath"
  local codexDir="${codexBin%/*}"
  [ -x "$codexDir/node" ] && launchPath="$codexDir:$launchPath"
  PATH="$launchPath" "$codexBin" -c "experimental_resume=$path"
}
# END codex-history-pick
