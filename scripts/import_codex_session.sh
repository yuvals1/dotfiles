#!/bin/bash

set -euo pipefail

DEFAULT_SESSIONS_DIR="~/.codex/sessions"
SAVED_SESSIONS_DIR="$HOME/codex_saved_sessions"

usage() {
    cat <<'EOF'
Usage: import_codex_session.sh <source> <target> <session_id> [title...]

Imports a Codex session JSONL from one machine/path to another so the target can run:
  codex resume <session_id>

Source/target forms:
  jetson19.local                         remote host, uses ~/.codex/sessions
  yuval@treex-dev-tlv                    remote host, uses ~/.codex/sessions
  jetson19.local:~/.codex/sessions/2026/05/27
                                          remote host with explicit search/copy path
  ~/.codex/sessions/2026/05/27           local path
  local                                  local ~/.codex/sessions

If target is not already a YYYY/MM/DD directory, the source session date is appended.
If title is provided, a local copy is saved under:
  ~/codex_saved_sessions/<title>/
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

target_dir_for() {
    local base
    base=$(trim_trailing_slashes "$1")
    local date_rel="$2"

    if [[ "$base" =~ /[0-9]{4}/[0-9]{2}/[0-9]{2}$ ]]; then
        printf '%s\n' "$base"
    else
        printf '%s/%s\n' "$base" "$date_rel"
    fi
}

derive_date_rel() {
    local found_path="$1"
    local file_name="$2"
    local metadata_file
    local metadata_date

    metadata_file="$(dirname "$found_path")/.codex_session_date"
    if [ -f "$metadata_file" ]; then
        metadata_date=$(sed -n '1p' "$metadata_file")
        if [[ "$metadata_date" =~ ^[0-9]{4}/[0-9]{2}/[0-9]{2}$ ]]; then
            printf '%s\n' "$metadata_date"
            return
        fi
    fi

    if [[ "$found_path" =~ /([0-9]{4})/([0-9]{2})/([0-9]{2})/[^/]+\.jsonl$ ]]; then
        printf '%s/%s/%s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
        return
    fi

    if [[ "$file_name" =~ ^rollout-([0-9]{4})-([0-9]{2})-([0-9]{2})T ]]; then
        printf '%s/%s/%s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
        return
    fi

    die "Could not derive session date from $found_path"
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
        quoted_name=$(sh_quote "*${session_id}.jsonl")
        ssh "$host" "find $quoted_path -type f -name $quoted_name -print" >"$output_file"
    else
        local local_path
        local_path=$(expand_local_path "$path")
        [ -d "$local_path" ] || die "Source path does not exist or is not a directory: $local_path"
        find "$local_path" -type f -name "*${session_id}.jsonl" -print | sort >"$output_file"
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
    local date_rel="$5"

    [ -n "$title" ] || return 0
    [[ "$title" != *"/"* ]] || die "Title cannot contain /"
    [ "$title" != "." ] && [ "$title" != ".." ] || die "Title cannot be . or .."

    local archive_dir="$SAVED_SESSIONS_DIR/$title"
    mkdir -p "$archive_dir"
    cp -f "$local_file" "$archive_dir/$file_name"
    printf '%s\n' "$session_id" >"$archive_dir/$session_id"
    printf '%s\n' "$date_rel" >"$archive_dir/.codex_session_date"
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
DATE_REL=$(derive_date_rel "$FOUND_PATH" "$FILE_NAME")
LOCAL_SESSION_FILE="$TMP_DIR/$FILE_NAME"
TARGET_DIR=$(target_dir_for "$TARGET_PATH" "$DATE_REL")

echo "Found: $FOUND_PATH"
echo "Copying session through local staging..."
copy_from_source "$SOURCE_REMOTE" "$SOURCE_HOST" "$FOUND_PATH" "$LOCAL_SESSION_FILE"
save_local_archive "$TITLE" "$SESSION_ID" "$LOCAL_SESSION_FILE" "$FILE_NAME" "$DATE_REL"
copy_to_target "$TARGET_REMOTE" "$TARGET_HOST" "$TARGET_DIR" "$LOCAL_SESSION_FILE"

if [ "$TARGET_REMOTE" = true ]; then
    echo "Imported session to $TARGET_HOST:$TARGET_DIR"
else
    echo "Imported session to $(expand_local_path "$TARGET_DIR")"
fi
echo "Resume on target with: codex resume $SESSION_ID"
