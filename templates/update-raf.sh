#!/bin/bash
set -eo pipefail

# cd to parent dir of current script
cd "$(dirname "${BASH_SOURCE[0]}")"
rafdir=$(realpath "$PWD")

die() {
    printf '%b\n' "$1" >&2
    exit "${2-1}"
}
log_has_substring() { grep "$1" "$logfile" >/dev/null 2>&1; }

logfile=$(mktemp)
cleanup_logfile() {
    rm "$logfile"
}; trap 'cleanup_logfile' EXIT


update() {
    path=$1
    strategy=$2
    postupdate=$3

    link=
    case $strategy in
        none)
            ;;
        link)
            link=true
            ;;
        *)
            die "don't know strategy: $strategy"
            ;;
    esac

    cd "$rafdir/$path"
    echo checking "$(basename "$PWD")"

    # update
    gitup > "$logfile" 2>&1 || die "[ERROR] during update $PWD\n\n$(cat "$logfile")"

    # post-update-hook?
    if ! log_has_substring "Already up to date."; then
        "$SHELL" -c "${postupdate:-:}" > "$logfile" 2>&1 \
            || die "[ERROR] during post-update hook $PWD\n\n$(cat "$logfile")" 
    fi

    # link?
    if [[ $link ]]; then
        install-local-bin "$(basename "$1")" > "$logfile" 2>&1 \
            || die "[ERROR] during linking $PWD\n\n$(cat "$logfile")"
        if ! log_has_substring "already correctly linked"; then
            cat "$logfile"
        fi
    fi
}

update "./autoversion" "link" "go build"
update "./ezautocompl" "link" "go build"
update "./gitusers"    "link" "go build"
update "./vscodevim"   "none" "./install.sh"
