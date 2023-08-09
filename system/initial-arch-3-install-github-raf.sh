#!/bin/bash
set -eo pipefail

[[ $EUID -eq 0 ]] && { echo "> don't run this as root"; exit 1; }

set -x
mkdir -p ~/workspace
cd ~/workspace

clone_build_and_link() {
    if [[ -d "$1" ]]; then
        return
    fi
    git clone "https://github.com/Rafflesiaceae/$1.git"
    pushd "$1"
    go build
    install-local-bin "$1"
    popd
}

clone_build_and_link gitusers
clone_build_and_link ezautocompl
clone_build_and_link autoversion
