#!/bin/bash

set -euo pipefail

SAVED_SESSIONS_DIR="$HOME/codex_saved_sessions"

usage() {
    cat <<'EOF'
Usage: export_codex_session.sh <title> <target> [session_id]

Exports a session saved under ~/codex_saved_sessions/<title>/ to another machine/path.
Any existing target JSONL for the same session id is deleted before export.

Examples:
  export_codex_session.sh train-yolo-on-depth jetson23.local
  export_codex_session.sh "friendly title" yuval@treex-dev-tlv
  export_codex_session.sh train-yolo-on-depth jetson23.local:~/.codex/sessions
EOF
}

die() {
    echo "Error: $*" >&2
    exit 1
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

trim_trailing_slashes() {
    local path="$1"
    while [ "$path" != "/" ] && [[ "$path" == */ ]]; do
        path=${path%/}
    done
    printf '%s\n' "$path"
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

sessions_root_for() {
    local path
    path=$(trim_trailing_slashes "$1")

    if [[ "$path" =~ ^(.*)/[0-9]{4}/[0-9]{2}/[0-9]{2}$ ]]; then
        printf '%s\n' "${BASH_REMATCH[1]}"
    else
        printf '%s\n' "$path"
    fi
}

target_dir_for() {
    local raw="$1"
    local date_rel="$2"
    local base
    local host
    local path

    if [[ "$raw" == *:* ]]; then
        host="${raw%%:*}"
        path="${raw#*:}"
        [ -n "$path" ] || path="~/.codex/sessions"
        base=$(trim_trailing_slashes "$path")
        if [[ "$base" =~ /[0-9]{4}/[0-9]{2}/[0-9]{2}$ ]]; then
            printf '%s:%s\n' "$host" "$base"
        else
            printf '%s:%s/%s\n' "$host" "$base" "$date_rel"
        fi
        return
    fi

    if is_local_host "$raw"; then
        printf '%s\n' "~/.codex/sessions/$date_rel"
        return
    fi

    local expanded
    expanded=$(expand_local_path "$raw")
    if [[ "$raw" == "~"* || "$raw" == /* || "$raw" == ./* || "$raw" == ../* || "$raw" == */* || -e "$expanded" ]]; then
        base=$(trim_trailing_slashes "$raw")
        if [[ "$base" =~ /[0-9]{4}/[0-9]{2}/[0-9]{2}$ ]]; then
            printf '%s\n' "$base"
        else
            printf '%s/%s\n' "$base" "$date_rel"
        fi
        return
    fi

    printf '%s:%s\n' "$raw" "~/.codex/sessions/$date_rel"
}

find_session_id_from_marker() {
    local archive_dir="$1"
    local marker
    local id
    local count=0
    local found=""

    while IFS= read -r marker; do
        id=$(basename "$marker")
        case "$id" in
            .*|*.jsonl)
                continue
                ;;
        esac
        [[ "$id" =~ ^[A-Za-z0-9_-]+$ ]] || continue
        [ "$(sed -n '1p' "$marker")" = "$id" ] || continue
        count=$((count + 1))
        found="$id"
    done < <(find "$archive_dir" -maxdepth 1 -type f -print | sort)

    if [ "$count" -eq 1 ]; then
        printf '%s\n' "$found"
        return
    fi

    if [ "$count" -gt 1 ]; then
        die "Multiple session id marker files found in $archive_dir; pass the session_id explicitly"
    fi

    return 1
}

find_session_id_from_jsonl() {
    local archive_dir="$1"
    local jsonl
    local base
    local id
    local count=0
    local found=""

    while IFS= read -r jsonl; do
        base=$(basename "$jsonl")
        if [[ "$base" =~ ([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})\.jsonl$ ]]; then
            id="${BASH_REMATCH[1]}"
            count=$((count + 1))
            found="$id"
        fi
    done < <(find "$archive_dir" -maxdepth 1 -type f -name '*.jsonl' -print | sort)

    if [ "$count" -eq 1 ]; then
        printf '%s\n' "$found"
        return
    fi

    if [ "$count" -gt 1 ]; then
        die "Multiple session JSONL files found in $archive_dir; pass the session_id explicitly"
    fi

    return 1
}

find_session_file() {
    local archive_dir="$1"
    local session_id="$2"
    local matches_file="$3"

    find "$archive_dir" -maxdepth 1 -type f -name "*${session_id}.jsonl" -print | sort >"$matches_file"
}

derive_date_rel() {
    local archive_dir="$1"
    local session_file="$2"
    local metadata_file="$archive_dir/.codex_session_date"
    local metadata_date
    local base
    local local_match

    if [ -f "$metadata_file" ]; then
        metadata_date=$(sed -n '1p' "$metadata_file")
        if [[ "$metadata_date" =~ ^[0-9]{4}/[0-9]{2}/[0-9]{2}$ ]]; then
            printf '%s\n' "$metadata_date"
            return
        fi
    fi

    base=$(basename "$session_file")
    local_match=$(find "$HOME/.codex/sessions" -type f -name "$base" -print 2>/dev/null | sort | sed -n '1p' || true)
    if [[ "$local_match" =~ /([0-9]{4})/([0-9]{2})/([0-9]{2})/[^/]+\.jsonl$ ]]; then
        printf '%s/%s/%s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
        return
    fi

    if [[ "$base" =~ ^rollout-([0-9]{4})-([0-9]{2})-([0-9]{2})T ]]; then
        printf '%s/%s/%s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
        return
    fi

    die "Could not derive session date from $session_file"
}

delete_existing_target_sessions() {
    local resolved_target="$1"
    local session_id="$2"
    local host
    local path
    local root
    local deleted_file="$TMP_DIR/deleted-target-sessions"

    : >"$deleted_file"

    if [[ "$resolved_target" == *:* ]]; then
        host="${resolved_target%%:*}"
        path="${resolved_target#*:}"
        root=$(sessions_root_for "$path")

        if is_local_host "$host"; then
            local local_root
            local_root=$(expand_local_path "$root")
            if [ -d "$local_root" ]; then
                find "$local_root" -type f -name "*${session_id}.jsonl" -print -exec rm -f -- {} + >"$deleted_file"
            fi
        else
            local quoted_root
            local quoted_name
            quoted_root=$(remote_path_expr "$root")
            quoted_name=$(sh_quote "*${session_id}.jsonl")
            ssh "$host" "if [ -d $quoted_root ]; then find $quoted_root -type f -name $quoted_name -print -exec rm -f -- {} +; fi" >"$deleted_file"
        fi
    else
        root=$(sessions_root_for "$resolved_target")
        local local_root
        local_root=$(expand_local_path "$root")
        if [ -d "$local_root" ]; then
            find "$local_root" -type f -name "*${session_id}.jsonl" -print -exec rm -f -- {} + >"$deleted_file"
        fi
    fi

    if [ -s "$deleted_file" ]; then
        local count
        count=$(awk 'END { print NR }' "$deleted_file")
        echo "Deleted $count existing target session file(s):"
        sed 's/^/  /' "$deleted_file"
    else
        echo "No existing target session file found for $session_id"
    fi
}

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    usage
    exit 1
fi

TITLE="$1"
TARGET="$2"
SESSION_ID="${3:-}"
ARCHIVE_DIR="$SAVED_SESSIONS_DIR/$TITLE"

[ -d "$ARCHIVE_DIR" ] || die "Saved session title not found: $ARCHIVE_DIR"

if [ -z "$SESSION_ID" ]; then
    SESSION_ID=$(find_session_id_from_marker "$ARCHIVE_DIR" || true)
fi

if [ -z "$SESSION_ID" ]; then
    SESSION_ID=$(find_session_id_from_jsonl "$ARCHIVE_DIR" || true)
fi

[ -n "$SESSION_ID" ] || die "Could not infer session id from $ARCHIVE_DIR"

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

MATCHES_FILE="$TMP_DIR/matches"
find_session_file "$ARCHIVE_DIR" "$SESSION_ID" "$MATCHES_FILE"
MATCH_COUNT=$(awk 'END { print NR }' "$MATCHES_FILE")

if [ "$MATCH_COUNT" -eq 0 ]; then
    die "No saved JSONL found for $SESSION_ID in $ARCHIVE_DIR"
fi

if [ "$MATCH_COUNT" -gt 1 ]; then
    echo "Found multiple matches:" >&2
    sed 's/^/  /' "$MATCHES_FILE" >&2
    die "Pass a more specific session_id"
fi

SESSION_FILE=$(sed -n '1p' "$MATCHES_FILE")
DATE_REL=$(derive_date_rel "$ARCHIVE_DIR" "$SESSION_FILE")
if [ ! -f "$ARCHIVE_DIR/.codex_session_date" ]; then
    printf '%s\n' "$DATE_REL" >"$ARCHIVE_DIR/.codex_session_date"
fi
RESOLVED_TARGET=$(target_dir_for "$TARGET" "$DATE_REL")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

delete_existing_target_sessions "$RESOLVED_TARGET" "$SESSION_ID"
"$SCRIPT_DIR/import_codex_session.sh" "$ARCHIVE_DIR" "$RESOLVED_TARGET" "$SESSION_ID"
