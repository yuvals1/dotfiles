# Show per-file line counts in forgit's gd picker while keeping forgit's
# original diff preview/action payload hidden behind the displayed label.
forgit::diff() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 1

    local -a files commits _forgit_diff_git_opts fzf_args
    local commit escaped_commits fzf_exit_code opts
    local forgit_bin preview_context sep added_color removed_color reset_color stats_header

    commits=()
    files=()
    [[ $# -ne 0 ]] && {
        if git rev-parse "$1" -- &>/dev/null; then
            if [[ $# -gt 1 ]] && git rev-parse "$2" -- &>/dev/null; then
                commits=("$1" "$2") && files=("${@:3}")
            else
                commits=("$1") && files=("${@:2}")
            fi
        else
            files=("$@")
        fi
    }

    escaped_commits=""
    for commit in "${commits[@]}"; do
        escaped_commits+="'${commit//\{/\\\\\{}' "
    done

    if [[ -n "$FORGIT_DIFF_GIT_OPTS" ]]; then
        _forgit_diff_git_opts=(${(z)FORGIT_DIFF_GIT_OPTS})
    else
        _forgit_diff_git_opts=()
    fi

    forgit_bin="${FORGIT:-$(command -v git-forgit)}"
    [[ -n "$forgit_bin" ]] || {
        print -u2 "git-forgit not found"
        return 1
    }

    preview_context="${FORGIT_PREVIEW_CONTEXT:-3}"
    sep=$'\x1f\x1e'
    added_color="$(git config --get-color color.diff.new green)"
    removed_color="$(git config --get-color color.diff.old red)"
    reset_color=$'\033[m'
    stats_header="$(
        git diff --numstat "${_forgit_diff_git_opts[@]}" "${commits[@]}" -- "${files[@]}" |
            awk \
                -v added_color="$added_color" \
                -v removed_color="$removed_color" \
                -v reset_color="$reset_color" '
                function is_number(value) {
                    return value ~ /^[0-9]+$/
                }
                {
                    if (is_number($1)) {
                        added += $1
                    }
                    if (is_number($2)) {
                        removed += $2
                    }
                }
                END {
                    header = "Total"
                    if (added > 0) {
                        header = header " " added_color "+" added reset_color
                    }
                    if (removed > 0) {
                        header = header " " removed_color "-" removed reset_color
                    }
                    if (header != "Total") {
                        print header
                    }
                }
            '
    )"
    fzf_args=()
    [[ -n "$stats_header" ]] && fzf_args=(--header="$stats_header")
    opts="
        $FZF_DEFAULT_OPTS
        --ansi
        --height='80%'
        --bind='alt-k:preview-up,alt-p:preview-up'
        --bind='alt-j:preview-down,alt-n:preview-down'
        --bind='ctrl-r:toggle-all'
        --bind='ctrl-s:toggle-sort'
        --bind='?:toggle-preview'
        --bind='alt-w:toggle-preview-wrap'
        --preview-window='right:60%'
        +1
        $FORGIT_FZF_DEFAULT_OPTS
        --delimiter=$sep
        --with-nth=1
        --accept-nth=2
        +m -0 --bind=\"enter:execute($forgit_bin diff_enter {2} $escaped_commits | $forgit_bin pager enter)\"
        --preview=\"$forgit_bin preview diff_view {2} '$preview_context' $escaped_commits\"
        --bind=\"alt-e:execute($forgit_bin edit_diffed_file {2})+refresh-preview\"
        $FORGIT_DIFF_FZF_OPTS
        --prompt=\"${commits[*]} > \"
    "

    paste \
        <(git diff --name-status "${_forgit_diff_git_opts[@]}" "${commits[@]}" -- "${files[@]}") \
        <(git diff --numstat "${_forgit_diff_git_opts[@]}" "${commits[@]}" -- "${files[@]}") |
        awk \
            -v sep="$sep" \
            -v added_color="$added_color" \
            -v removed_color="$removed_color" \
            -v reset_color="$reset_color" '
            function clean_count(value) {
                if (value == "") {
                    return "0"
                }
                if (value == "-") {
                    return "?"
                }
                return value
            }
            {
                status = $1
                if (status ~ /^[RC]/) {
                    path = $2 "  ->  " $3
                    added = clean_count($4)
                    removed = clean_count($5)
                } else {
                    path = $2
                    added = clean_count($3)
                    removed = clean_count($4)
                }
                payload = "[" status "]\t" path
                label = "[" status "]"
                if (added + 0 > 0) {
                    label = label " " added_color "+" added reset_color
                }
                if (removed + 0 > 0) {
                    label = label " " removed_color "-" removed reset_color
                }
                printf "%s %s%s%s\n", label, path, sep, payload
            }
        ' |
        FZF_DEFAULT_OPTS="$opts" fzf "${fzf_args[@]}"
    fzf_exit_code=$?
    [[ $fzf_exit_code == 130 ]] && return 0
    return $fzf_exit_code
}
