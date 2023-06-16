#!/bin/bash
set -eo pipefail

die() {
    printf '%s\n' "$1" >&2
    exit "${2-1}"
}

# @TODO consider pacman T ... instead of --needed

echo "> check for sudo"
command -v sudo &>/dev/null || die "please install and setup sudo first"

echo "> get first deps"
sudo pacman -S \
    --needed \
    asciinema \
	curl \
	pacman-contrib

# record itself
if [[ "$1" != "--no-record" ]]; then
    title="initial_arch_packages_$(date +%s)"
    castfile=$HOME/.$title.cast
    echo "recording output to $castfile"
    asciinema rec \
        --command "\"$0\" --no-record" \
        --title "$title" \
        --quiet \
        "$castfile"
    exit 0
fi

echo "> rank and write /etc/pacman.d/mirrorlist"
if [[ ! -f "/etc/pacman.d/mirrorlist" ]]; then
    tmpfile=$(mktemp)
    curl -L -s 'https://archlinux.org/mirrorlist/?country=AT&country=DE&protocol=https&use_mirror_status=on' | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 5 - >"$tmpfile"
    sudo mv "$tmpfile" "/etc/pacman.d/mirrorlist"
fi

echo "> refresh db"
sudo pacman -Sy

echo "> install system packages"
base=(
    android-tools
    android-udev
    aria2
    asciinema
    atool
    btrfs-progs
    cifs-utils
    curl
    dbus
    docker
    docker-buildx
    docker-compose
    dos2unix
    entr
    fzf
    git
    git-filter-repo
    glances
    gnome-keyring
    gsmartcontrol
    gvfs
    gvfs-mtp
    gvfs-nfs
    gvfs-smb
    gvim
    highlight
    htop
    hyperfine
    imagemagick
    jq
    linux-headers
    maim
    man-db
    man-pages
    mlocate
    ncdu
    neovim
    nmap
    openssh
    p7zip
    packer
    pacman-contrib
    pkg-config
    polkit
    pulseaudio
    pulseaudio-alsa
    python-pynvim
    qemu
    ranger
    ripgrep
    rsync
    shellcheck
    smbclient
    socat
    sudo
    tesseract
    tesseract-data-deu
    tesseract-data-eng
    tmux
    traceroute
    tree
    udisks2
    unrar
    unzip
    urxvt-perls
    usbutils
    wget
    whois
    wine
    xdg-user-dirs
    youtube-dl
    yq
    zip
    zsh
)

x11=(
    # xorg-xbacklight # conflicts with acpilight
    d-feet
    dunst
    freetype2
    i3-wm
    i3blocks
    i3lock
    i3status
    libinput
    lightdm
    lightdm-gtk-greeter
    numlockx
    parcellite
    rofi
    seahorse
    tigervnc
    ttf-droid
    ttf-liberation
    xclip
    xf86-input-libinput
    xorg-mkfontscale
    xorg-server
    xorg-xgamma
    xorg-xinput
    xorg-xkill
    xorg-xmodmap
    xorg-xrdb
    xsel
)

gui_applications=(
    audacity
    catfish
    chromium
    eog
    evince
    gcolor2
    gdmap
    geany
    gimp
    gparted
    inkscape
    keepass
    libreoffice-fresh
    llpp
    lxrandr
    mpv
    pavucontrol
    rdesktop
    thunar
    thunar-archive-plugin
    thunar-media-tags-plugin
    thunar-volman
    thunderbird
    vlc
    vscode
)
dev=(
    base-devel
    clang
    cmake
    ctags
    gdb
    go
    godot
    intellij-idea-community-edition
    llvm
    meson
    nodejs
    npm
    ocaml
    ocaml-findlib
    opam
    pyenv
    python-jinja
    python-lxml
    python-pillow
    python-pipenv
    python-pynvim
    python-requests
    python-yaml
    qt5-tools
    qtcreator
    rustup
    tidy
    tig
    tup
    yarn
)
network=(
    connman
)
printer=(
    cups
    cups-pdf
)
amd=(
    mesa-vdpau
)
all=(
    "${base[@]}"
    "${x11[@]}"
    "${gui_applications[@]}"
    "${dev[@]}"
    "${network[@]}"
    "${printer[@]}"
)

sudo pacman -S \
    --needed \
    "${all[@]}"

echo "> install aur packages"
aur=(
    deadbeef-git
    nimbus-git
    ttf-symbola
    ttf-vista-fonts
    )

yay -S \
    --answerclean None \
    --answerdiff None \
    "${aur[@]}"
