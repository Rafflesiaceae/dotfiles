#!/bin/bash
set -eo pipefail

die() {
    printf '%s\n' "$1" >&2
    exit "${2-1}"
}
prompt() {
    tput sc
    while true; do
        read -p "${1-Continue?} (y/n) " -n 1 -r yn </dev/tty
        case $yn in
            [Yy]*) return;;
            [Nn]*) return 1;;
            *) tput el1; tput rc ;;
        esac
    done
    printf "\n"
}

tmpdir=$PWD/tmp

[[ -d "$tmpdir" ]] && die "$tmpdir shouldnt exist"

cleanupTempdir() {
    [[ -d "$tmpdir" ]] && sudo rm -r "$tmpdir"
}
trap 'cleanupTempdir' EXIT

sudo mkdir "$tmpdir" || die "could not make $tmpdir"

is_owned_by_root() { [[ "$(stat --printf "%G" "$1")" == "root" ]]; }

sudo_vimdiff() {
    # copy file to ./tmp/..., which is a root-owned path in order to appease sudoedit
    src=$(realpath -m "$tmpdir/$f")
    sudo mkdir -p "$(dirname "$src")"
    sudo cp "$f" "$src"
    sudo chown root:root "$src"

    # assert perms
    is_owned_by_root "$src" || die "$src doesnt belong to root"

    (set -x; svimdiff "$src" "$target" </dev/tty)
}



find . -type f | while read -r f ; do
    # [[ "$f" == *"$(basename "$0")" ]] && continue # skip this script itself
    [[ "$(echo "$f" | awk -F"/" '{print NF-1}')" -lt 2 ]] && continue # skip root files

    echo ""
    echo "> $f"

    target=$(realpath -m "/$(echo "$f" | sed -e "s/\$USER/$USER/g" )")

    # skip if the target is the same
    if sudo cmp -s "$target" "$f"; then
        { echo "$target is already up to date, skipping..."; continue; }
    fi


    # skip if the target doesnt exist
    if ! sudo test -f "$target"; then
	if prompt "$target doesnt exist, copy template?"; then
        sudo mkdir -p "$(dirname "$target")"
		sudo cp "$f" "$target"
		sudoedit "$target" </dev/tty
	fi
	continue
    fi

    sleep 1

    # either sudoedit or normal vimdiff
    if is_owned_by_root "$target"; then
        sudo_vimdiff
    else
        (set -x; vimdiff "$f" "$target" </dev/tty)
    fi
done
