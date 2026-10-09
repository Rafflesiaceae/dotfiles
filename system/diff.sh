#!/bin/bash
set -eo pipefail

[[ $EUID -eq 0 ]] && { echo "> don't run this as root"; exit 1; }

die() {
    printf '%s\n' "$1" >&2
    exit "${2-1}"
}

# All three flags select home files and avoid every privileged operation.
home_only=false
for arg in "$@"; do
    case $arg in
        --user|--local|--home) home_only=true ;;
        *) die "usage: $0 [--user|--local|--home]" ;;
    esac
done

run_as_root=(sudo)
source_root=.
if $home_only; then
    run_as_root=()
    source_root=./home
fi

prompt() {
    tput sc
    while true; do
        read -p "${1-Continue?} (y/n) " -n 1 -r yn
        case $yn in
            [Yy]*) return;;
            [Nn]*) return 1;;
            *) tput el1; tput rc ;;
        esac
    done
    printf "\n"
}

{ # initial checks
    if ! $home_only; then
        command -v sudoedit &>/dev/null || die "can't find program: sudoedit"
    fi
}

tmpdir=$PWD/tmp

cleanupTempdir() {
    [[ -d "$tmpdir" ]] && sudo rm -r "$tmpdir"
}

# Only sudoedit needs a root-owned temporary directory.
if ! $home_only; then
    [[ -d "$tmpdir" ]] && die "$tmpdir shouldnt exist"
    trap 'cleanupTempdir' EXIT
    sudo mkdir "$tmpdir" || die "could not make $tmpdir"
fi

is_owned_by_root() { [[ "$(stat --printf "%G" "$1")" == "root" ]]; }

sudo_vimdiff() {
    # copy file to ./tmp/..., which is a root-owned path in order to appease sudoedit
    src=$(realpath -m "$tmpdir/$f")
    sudo mkdir -p "$(dirname "$src")"
    sudo cp "$f" "$src"
    sudo chown root:root "$src"

    # assert perms
    is_owned_by_root "$src" || die "$src doesnt belong to root"

    (set -x; svimdiff "$src" "$target")
}


while read -r f; do
{
    [[ "$(echo "$f" | awk -F"/" '{print NF-1}')" -lt 2 ]] && continue # skip root files

    echo ""
    echo "> $f"

    target=$(realpath -m "/$(echo "$f" | sed -e "s/\$USER/$USER/g" )")

    # Home-only mode must never fall back to sudo for protected files.
    if $home_only && [[ -e $target ]]; then
        if [[ ! -r $target || ! -w $target ]] || is_owned_by_root "$target"; then
            echo "$target requires elevated permissions, skipping..."
            continue
        fi
    fi

    # skip if the target is the same
    if "${run_as_root[@]}" cmp -s "$target" "$f"; then
        echo "$target is already up to date, skipping..."
        continue
    fi


    # skip if the target doesnt exist
    if ! "${run_as_root[@]}" test -f "$target"; then
        # Check the nearest existing parent before offering to create a file.
        if $home_only; then
            parent=$(dirname "$target")
            while [[ ! -e $parent ]]; do
                parent=$(dirname "$parent")
            done
            if [[ ! -d $parent || ! -w $parent || ! -x $parent ]]; then
                echo "$target requires elevated permissions, skipping..."
                continue
            fi
        fi
        if prompt "$target doesnt exist, copy template?"; then
             if $home_only || [[ $target == /home/* ]]; then
                mkdir -p "$(dirname "$target")"
                cp "$f" "$target"
                vim "$target"
             else
                sudo mkdir -p "$(dirname "$target")"
                sudo cp "$f" "$target"
                sudoedit "$target"
             fi
        fi
        continue
    fi

    sleep 1

    # either sudoedit or normal vimdiff
    if ! $home_only && is_owned_by_root "$target"; then
        sudo_vimdiff
    else
        (set -x; vimdiff "$f" "$target")
    fi
} < /dev/tty
done < <(find "$source_root" -type f)
