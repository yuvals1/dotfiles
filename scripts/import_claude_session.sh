#!/bin/bash

set -euo pipefail

DEFAULT_SESSIONS_DIR="~/.claude/projects"
SAVED_SESSIONS_DIR="$HOME/claude_saved_sessions"

usage() {
    cat <<'EOF'
Usage: import_claude_session.sh <source> <target> <session_id> [title...]

Imports a Claude Code session JSONL from one machine/path to another so the target can run:
  claude --resume <session_id>

Source/target forms:
  jetson19.local                         remote host, uses ~/.claude/projects
  yuval@treex-dev-tlv                    remote host, uses ~/.claude/projects
  jetson19.local:~/.claude/projects/-home-yuval-dotfiles
                                          remote host with explicit project directory
  ~/.claude/projects/-Users-yuvalspiegel-dotfiles
                                          local path
  local                                  local ~/.claude/projects

Sessions live under a per-project directory named after the working directory
with every non-alphanumeric character replaced by a dash
(e.g. /home/yuval/dotfiles -> -home-yuval-dotfiles).

The target project directory is resolved automatically: the session's original
working directory is read from the JSONL, and the target is searched for that
path or a directory with the same name under ~/ and ~/../. If nothing is
found, the source project directory name is kept as-is; pass an explicit
project directory in the target to override.

If title is provided, a local copy is saved under:
  ~/claude_saved_sessions/<title>/
EOF
}

die() {
    echo "Error: $*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

is_local_host() {
    case "$1" in
        local|localhost|127.0.0.1|::1)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

expand_local_path() {
    case "$1" in
        "~")
            printf '%s\n' "$HOME"
            ;;
        "~/"*)
            printf '%s/%s\n' "$HOME" "${1#\~/}"
            ;;
        *)
            printf '%s\n' "$1"
            ;;
    esac
}

sh_quote() {
    local value="$1"
    value=${value//\'/\'\\\'\'}
    printf "'%s'" "$value"
}

remote_path_expr() {
    case "$1" in
        "~")
            printf '"$HOME"'
            ;;
        "~/"*)
            printf '"$HOME"/%s' "$(sh_quote "${1#\~/}")"
            ;;
        *)
            sh_quote "$1"
            ;;
    esac
}

trim_trailing_slashes() {
    local path="$1"
    while [ "$path" != "/" ] && [[ "$path" == */ ]]; do
        path=${path%/}
    done
    printf '%s\n' "$path"
}

parse_endpoint() {
    local raw="$1"
    ENDPOINT_REMOTE=false
    ENDPOINT_HOST=""
    ENDPOINT_PATH=""

    if [[ "$raw" == *:* ]]; then
        ENDPOINT_HOST="${raw%%:*}"
        ENDPOINT_PATH="${raw#*:}"
        [ -n "$ENDPOINT_PATH" ] || ENDPOINT_PATH="$DEFAULT_SESSIONS_DIR"

        if is_local_host "$ENDPOINT_HOST"; then
            ENDPOINT_REMOTE=false
            ENDPOINT_HOST=""
        else
            ENDPOINT_REMOTE=true
        fi
        return
    fi

    if is_local_host "$raw"; then
        ENDPOINT_PATH="$DEFAULT_SESSIONS_DIR"
        return
    fi

    local expanded
    expanded=$(expand_local_path "$raw")
    if [[ "$raw" == "~"* || "$raw" == /* || "$raw" == ./* || "$raw" == ../* || "$raw" == */* || -e "$expanded" ]]; then
        ENDPOINT_PATH="$raw"
        return
    fi

    ENDPOINT_REMOTE=true
    ENDPOINT_HOST="$raw"
    ENDPOINT_PATH="$DEFAULT_SESSIONS_DIR"
}

is_project_dir_name() {
    [[ "$1" == -* ]]
}

# Claude Code derives the project directory from the working directory with
# every non-alphanumeric character replaced by a dash.
flatten_path() {
    printf '%s\n' "$1" | sed 's/[^A-Za-z0-9]/-/g'
}

extract_session_cwd() {
    grep -m1 -o '"cwd":"[^"]*"' "$1" 2>/dev/null | cut -d'"' -f4 || true
}

derive_source_project_rel() {
    local found_path="$1"
    local session_cwd="$2"
    local metadata_file
    local metadata_project
    local parent_name

    parent_name=$(basename "$(dirname "$found_path")")
    if is_project_dir_name "$parent_name"; then
        printf '%s\n' "$parent_name"
        return
    fi

    metadata_file="$(dirname "$found_path")/.claude_session_project"
    if [ -f "$metadata_file" ]; then
        metadata_project=$(sed -n '1p' "$metadata_file")
        if is_project_dir_name "$metadata_project"; then
            printf '%s\n' "$metadata_project"
            return
        fi
    fi

    if [ -n "$session_cwd" ]; then
        flatten_path "$session_cwd"
        return
    fi

    die "Could not derive project directory from $found_path"
}

# Looks on the target for the session's original working directory, or a
# directory with the same name under $HOME and $HOME/.., and sets
# RESOLVED_PROJECT_REL to its flattened form. Leaves it empty when nothing is
# found; dies when the search is ambiguous.
resolve_target_project_rel() {
    local remote="$1"
    local host="$2"
    local session_cwd="$3"

    RESOLVED_PROJECT_REL=""
    [ -n "$session_cwd" ] || return 0

    local repo_name
    repo_name=$(basename "$session_cwd")

    local finder
    finder="if [ -d $(sh_quote "$session_cwd") ]; then printf '%s\n' $(sh_quote "$session_cwd"); else { find \"\$HOME\" -mindepth 1 -maxdepth 2 -type d -name $(sh_quote "$repo_name") -not -path '*/.*' 2>/dev/null; find \"\$(dirname \"\$HOME\")\" -mindepth 2 -maxdepth 2 -type d -name $(sh_quote "$repo_name") -not -path '*/.*' 2>/dev/null; } | sort -u; fi"

    local candidates_file="$TMP_DIR/target_candidates"
    if [ "$remote" = true ]; then
        require_command ssh
        ssh "$host" "$finder" >"$candidates_file"
    else
        sh -c "$finder" >"$candidates_file"
    fi

    sed -i.bak '/^$/d' "$candidates_file" 2>/dev/null || true

    local count
    count=$(awk 'END { print NR }' "$candidates_file")
    if [ "$count" -eq 0 ]; then
        return 0
    fi
    if [ "$count" -gt 1 ]; then
        echo "Found multiple candidate directories for $repo_name on target:" >&2
        sed 's/^/  /' "$candidates_file" >&2
        die "Pass an explicit target project directory, e.g. host:~/.claude/projects/\$(printf '%s' /path/to/$repo_name | sed 's/[^A-Za-z0-9]/-/g')"
    fi

    local candidate
    candidate=$(sed -n '1p' "$candidates_file")
    echo "Resolved target working directory: $candidate"
    RESOLVED_PROJECT_REL=$(flatten_path "$candidate")
}

find_session_file() {
    local remote="$1"
    local host="$2"
    local path="$3"
    local session_id="$4"
    local output_file="$5"

    if [ "$remote" = true ]; then
        require_command ssh
        local quoted_path
        quoted_path=$(remote_path_expr "$path")
        local quoted_name
        quoted_name=$(sh_quote "${session_id}.jsonl")
        ssh "$host" "find $quoted_path -type f -name $quoted_name -print" >"$output_file"
    else
        local local_path
        local_path=$(expand_local_path "$path")
        [ -d "$local_path" ] || die "Source path does not exist or is not a directory: $local_path"
        find "$local_path" -type f -name "${session_id}.jsonl" -print | sort >"$output_file"
    fi
}

copy_from_source() {
    local remote="$1"
    local host="$2"
    local found_path="$3"
    local destination="$4"

    if [ "$remote" = true ]; then
        require_command rsync
        rsync -az "$host:$found_path" "$destination"
    else
        cp -f "$found_path" "$destination"
    fi
}

copy_to_target() {
    local remote="$1"
    local host="$2"
    local target_dir="$3"
    local local_file="$4"

    if [ "$remote" = true ]; then
        require_command ssh
        require_command rsync
        local quoted_target_dir
        quoted_target_dir=$(remote_path_expr "$target_dir")
        ssh "$host" "mkdir -p -- $quoted_target_dir"
        rsync -az "$local_file" "$host:$target_dir/"
    else
        local local_target_dir
        local_target_dir=$(expand_local_path "$target_dir")
        mkdir -p "$local_target_dir"
        cp -f "$local_file" "$local_target_dir/"
    fi
}

save_local_archive() {
    local title="$1"
    local session_id="$2"
    local local_file="$3"
    local file_name="$4"
    local project_rel="$5"

    [ -n "$title" ] || return 0
    [[ "$title" != *"/"* ]] || die "Title cannot contain /"
    [ "$title" != "." ] && [ "$title" != ".." ] || die "Title cannot be . or .."

    local archive_dir="$SAVED_SESSIONS_DIR/$title"
    mkdir -p "$archive_dir"
    cp -f "$local_file" "$archive_dir/$file_name"
    printf '%s\n' "$session_id" >"$archive_dir/$session_id"
    printf '%s\n' "$project_rel" >"$archive_dir/.claude_session_project"
    echo "Saved local archive: $archive_dir"
}

if [ "$#" -lt 3 ]; then
    usage
    exit 1
fi

SOURCE_ARG="$1"
TARGET_ARG="$2"
SESSION_ID="$3"
shift 3
TITLE="${*:-}"

case "$SESSION_ID" in
    ""|*[!A-Za-z0-9_-]*)
        die "Session id must contain only letters, numbers, hyphens, or underscores"
        ;;
esac

TMP_DIR=$(mktemp -d)
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

parse_endpoint "$SOURCE_ARG"
SOURCE_REMOTE="$ENDPOINT_REMOTE"
SOURCE_HOST="$ENDPOINT_HOST"
SOURCE_PATH="$ENDPOINT_PATH"

parse_endpoint "$TARGET_ARG"
TARGET_REMOTE="$ENDPOINT_REMOTE"
TARGET_HOST="$ENDPOINT_HOST"
TARGET_PATH="$ENDPOINT_PATH"

MATCHES_FILE="$TMP_DIR/matches"
echo "Searching for session $SESSION_ID in $SOURCE_ARG..."
find_session_file "$SOURCE_REMOTE" "$SOURCE_HOST" "$SOURCE_PATH" "$SESSION_ID" "$MATCHES_FILE"

MATCH_COUNT=$(awk 'END { print NR }' "$MATCHES_FILE")
if [ "$MATCH_COUNT" -eq 0 ]; then
    die "No session JSONL found for $SESSION_ID in $SOURCE_ARG"
fi

if [ "$MATCH_COUNT" -gt 1 ]; then
    echo "Found multiple matches:" >&2
    sed 's/^/  /' "$MATCHES_FILE" >&2
    die "Use a narrower source path"
fi

FOUND_PATH=$(sed -n '1p' "$MATCHES_FILE")
FILE_NAME=$(basename "$FOUND_PATH")
LOCAL_SESSION_FILE="$TMP_DIR/$FILE_NAME"

echo "Found: $FOUND_PATH"
echo "Copying session through local staging..."
copy_from_source "$SOURCE_REMOTE" "$SOURCE_HOST" "$FOUND_PATH" "$LOCAL_SESSION_FILE"

SESSION_CWD=$(extract_session_cwd "$LOCAL_SESSION_FILE")
SOURCE_PROJECT_REL=$(derive_source_project_rel "$FOUND_PATH" "$SESSION_CWD")
save_local_archive "$TITLE" "$SESSION_ID" "$LOCAL_SESSION_FILE" "$FILE_NAME" "$SOURCE_PROJECT_REL"

TARGET_BASE=$(trim_trailing_slashes "$TARGET_PATH")
if is_project_dir_name "$(basename "$TARGET_BASE")"; then
    TARGET_DIR="$TARGET_BASE"
else
    resolve_target_project_rel "$TARGET_REMOTE" "$TARGET_HOST" "$SESSION_CWD"
    if [ -n "$RESOLVED_PROJECT_REL" ]; then
        PROJECT_REL="$RESOLVED_PROJECT_REL"
    else
        PROJECT_REL="$SOURCE_PROJECT_REL"
        echo "Warning: could not locate the session's project on the target; keeping source project directory $PROJECT_REL" >&2
        echo "Resume will only find it if the target working directory flattens to that name." >&2
    fi
    TARGET_DIR="$TARGET_BASE/$PROJECT_REL"
fi

copy_to_target "$TARGET_REMOTE" "$TARGET_HOST" "$TARGET_DIR" "$LOCAL_SESSION_FILE"

if [ "$TARGET_REMOTE" = true ]; then
    echo "Imported session to $TARGET_HOST:$TARGET_DIR"
else
    echo "Imported session to $(expand_local_path "$TARGET_DIR")"
fi
echo "Resume on target with: claude --resume $SESSION_ID"
