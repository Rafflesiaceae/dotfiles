#!/bin/bash
set -eo pipefail

[[ $EUID -eq 0 ]] && { echo "> don't run this as root"; exit 1; }

# cd to parent dir of current script
cd "$(dirname "${BASH_SOURCE[0]}")"

copy_if_not_exist() {
    if [[ ! -f "$2" ]]; then
        if [[ "$3" == "sudo" ]]; then
            ( set -x; sudo cp "$1" "$2" )
        else
            ( set -x; cp "$1" "$2" )
        fi
    else
        echo "$2 already exists, skipping ..."
    fi
}

copy_if_not_exist ./home/\$USER/.profile               "$HOME/.profile"
copy_if_not_exist ./etc/profile.d/editor.sh            /etc/profile.d/editor.sh            sudo
copy_if_not_exist ./etc/profile.d/homebin.sh           /etc/profile.d/homebin.sh           sudo
copy_if_not_exist ./etc/profile.d/homebin_override.sh  /etc/profile.d/homebin_override.sh  sudo

mkdir -p $HOME/.cache/zsh
mkdir -p $HOME/.vim/backup
touch $HOME/.cache/zsh/dirs

echo "> please relogin/restart for profile.d changes to take effect"
