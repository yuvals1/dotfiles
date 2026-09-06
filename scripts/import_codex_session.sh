#!/bin/bash

set -euo pipefail

DEFAULT_SESSIONS_DIR="~/.codex/sessions"
SAVED_SESSIONS_DIR="$HOME/codex_saved_sessions"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HISTORY_HELPER="$SCRIPT_DIR/codex_session_history.py"

usage() {
    cat <<'EOF'
Usage: import_codex_session.sh <source> <target> <session_id> [title...]

Imports a Codex session and all required source rollouts so the target can run:
  codex resume <session_id>

Source/target forms:
  jetson19.local                         remote host, uses ~/.codex/sessions
  yuval@treex-dev-tlv                    remote host, uses ~/.codex/sessions
  jetson19.local:~/.codex/sessions/2026/05/27
                                          remote host with explicit search/copy path
  ~/.codex/sessions/2026/05/27           local path
  local                                  local ~/.codex/sessions

If target is not already a YYYY/MM/DD directory, the source session date is appended.
History dependencies are resolved across dates in the enclosing session tree.
Requires Python 3 to validate JSON metadata; existing source histories are preserved.
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
        ssh -n "$host" "find $quoted_path -type f -name $quoted_name -print" >"$output_file"
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
    local preserve_existing="${5:-false}"

    if [ "$remote" = true ]; then
        require_command ssh
        require_command rsync
        local quoted_target_dir
        quoted_target_dir=$(remote_path_expr "$target_dir")
        ssh -n "$host" "mkdir -p -- $quoted_target_dir"
        if [ "$preserve_existing" = true ]; then
            rsync -az --ignore-existing "$local_file" "$host:$target_dir/"
        else
            rsync -az "$local_file" "$host:$target_dir/"
        fi
    else
        local local_target_dir
        local_target_dir=$(expand_local_path "$target_dir")
        mkdir -p "$local_target_dir"
        if [ "$preserve_existing" = true ]; then
            if [ ! -e "$local_target_dir/$(basename "$local_file")" ]; then
                cp -n "$local_file" "$local_target_dir/"
            fi
        else
            cp -f "$local_file" "$local_target_dir/"
        fi
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

history_tree_for() {
    local path
    path=$(trim_trailing_slashes "$1")
    if [[ "$path" =~ ^(.*)/[0-9]{4}/[0-9]{2}/[0-9]{2}$ ]]; then
        printf '%s\n' "${BASH_REMATCH[1]}"
    else
        printf '%s\n' "$path"
    fi
}

check_target_history() {
    local path="$1" bytes="$2" digest="$3"
    if [ "$TARGET_REMOTE" = true ]; then
        ssh "$TARGET_HOST" "python3 - check-existing $(sh_quote "$path") $(sh_quote "$bytes") $(sh_quote "$digest")" <"$HISTORY_HELPER"
    else
        python3 "$HISTORY_HELPER" check-existing "$(expand_local_path "$path")" "$bytes" "$digest"
    fi
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
require_command python3
[ -f "$HISTORY_HELPER" ] || die "Missing history helper: $HISTORY_HELPER"
if [ -n "$TITLE" ]; then
    [[ "$TITLE" != *"/"* && "$TITLE" != "." && "$TITLE" != ".." ]] || die "Invalid archive title"
fi

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
TARGET_DIR=$(target_dir_for "$TARGET_PATH" "$DATE_REL")
SELECTED_FILE_NAME="$FILE_NAME"
SELECTED_DATE_REL="$DATE_REL"
HISTORY_SOURCE_PATH=$(history_tree_for "$(dirname "$FOUND_PATH")")
HISTORY_TARGET_PATH=$(history_tree_for "$TARGET_PATH")

echo "Found: $FOUND_PATH"
echo "Staging and validating the complete session history..."
CURRENT_ID="$SESSION_ID"
SEEN_IDS="|"
while [ -n "$CURRENT_ID" ]; do
    [[ "$SEEN_IDS" != *"|$CURRENT_ID|"* ]] || die "History dependency cycle: $CURRENT_ID"
    SEEN_IDS="$SEEN_IDS$CURRENT_ID|"
    FILE_NAME=$(basename "$FOUND_PATH")
    DATE_REL=$(derive_date_rel "$FOUND_PATH" "$FILE_NAME")
    copy_from_source "$SOURCE_REMOTE" "$SOURCE_HOST" "$FOUND_PATH" "$TMP_DIR/$FILE_NAME"
    printf '%s\n' "$DATE_REL" >"$TMP_DIR/$FILE_NAME.date"
    CURRENT_ID=$(python3 "$HISTORY_HELPER" parent "$TMP_DIR/$FILE_NAME" "$CURRENT_ID")
    [ -n "$CURRENT_ID" ] || break
    find_session_file "$SOURCE_REMOTE" "$SOURCE_HOST" "$HISTORY_SOURCE_PATH" "$CURRENT_ID" "$MATCHES_FILE"
    MATCH_COUNT=$(awk 'END { print NR }' "$MATCHES_FILE")
    [ "$MATCH_COUNT" -ne 0 ] || die "Missing source rollout: $CURRENT_ID in $HISTORY_SOURCE_PATH"
    [ "$MATCH_COUNT" -eq 1 ] || die "Ambiguous source rollout: $CURRENT_ID in $HISTORY_SOURCE_PATH"
    FOUND_PATH=$(sed -n '1p' "$MATCHES_FILE")
done

MANIFEST="$TMP_DIR/history.tsv"
python3 "$HISTORY_HELPER" manifest "$TMP_DIR" "$SESSION_ID" >"$MANIFEST"
# Reject target conflicts before publishing any part of the session.
while IFS=$'\t' read -r FILE_NAME REQUIRED_BYTES PREFIX_DIGEST; do
    [ "$REQUIRED_BYTES" != "-" ] || continue
    DATE_REL=$(cat "$TMP_DIR/$FILE_NAME.date")
    HISTORY_DIR=$(target_dir_for "$HISTORY_TARGET_PATH" "$DATE_REL")
    check_target_history "$HISTORY_DIR/$FILE_NAME" "$REQUIRED_BYTES" "$PREFIX_DIGEST" >/dev/null
done <"$MANIFEST"

while IFS=$'\t' read -r FILE_NAME REQUIRED_BYTES PREFIX_DIGEST; do
    DATE_REL=$(cat "$TMP_DIR/$FILE_NAME.date")
    if [ "$REQUIRED_BYTES" = "-" ]; then
        copy_to_target "$TARGET_REMOTE" "$TARGET_HOST" "$TARGET_DIR" "$TMP_DIR/$FILE_NAME"
    else
        HISTORY_DIR=$(target_dir_for "$HISTORY_TARGET_PATH" "$DATE_REL")
        copy_to_target "$TARGET_REMOTE" "$TARGET_HOST" "$HISTORY_DIR" "$TMP_DIR/$FILE_NAME" true
        check_target_history "$HISTORY_DIR/$FILE_NAME" "$REQUIRED_BYTES" "$PREFIX_DIGEST" >/dev/null
    fi
    if [ -n "$TITLE" ] && [ "$REQUIRED_BYTES" != "-" ]; then
        ARCHIVE_DATE_DIR="$SAVED_SESSIONS_DIR/$TITLE/$DATE_REL"
        mkdir -p "$ARCHIVE_DATE_DIR"
        cp -f "$TMP_DIR/$FILE_NAME" "$ARCHIVE_DATE_DIR/$FILE_NAME"
    fi
done <"$MANIFEST"
save_local_archive "$TITLE" "$SESSION_ID" "$TMP_DIR/$SELECTED_FILE_NAME" "$SELECTED_FILE_NAME" "$SELECTED_DATE_REL"
echo "Transferred $(awk 'END { print NR }' "$MANIFEST") rollout file(s)."

if [ "$TARGET_REMOTE" = true ]; then
    echo "Imported session to $TARGET_HOST:$TARGET_DIR"
else
    echo "Imported session to $(expand_local_path "$TARGET_DIR")"
fi
echo "Resume on target with: codex resume $SESSION_ID"
