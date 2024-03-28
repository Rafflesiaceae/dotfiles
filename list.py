import common

# sources {{{1
sources = {
    # <source>: <target> (empty means same as source)

    "./.config/.bazelrc": "./.bazelrc",
    "./.config/.ripgreprc": { "linux": "" },
    "./.config/.yamlfmt": "",
    "./.config/Thunar/uca.xml": { "linux": "" },
    "./.config/alacritty/alacritty.yml.j2": { "linux": "", "windows": "AppData/Roaming/alacritty/alacritty.yml" },
    "./.config/dunst/dunstrc": { "linux": "" },
    "./.config/ezautocompl.yml": "",
    "./.config/fontconfig/fonts.conf": { "linux": "" },
    "./.config/fontconfig/no-subpixels-fonts.conf": { "linux": "" },
    "./.config/i3/config.j2": { "linux": "" },
    "./.config/llpp.conf": { "linux": "" },
    "./.config/mpv/config": { "linux": "", "windows": "~/scoop/apps/mpv/current/portable_config/config" },
    "./.config/mpv/input.conf": { "linux": "" },
    "./.config/mpv/scripts/global-vol.lua": "",
    "./.config/nvim/.editorconfig": "",
    "./.config/nvim/autoload/airline/themes/base16_kokonai.vim": { "linux": "" },
    "./.config/nvim/colors/base16-kokonai.vim": { "linux": "" },
    "./.config/nvim/init.vim": "",
    "./.config/parcellite/parcelliterc": { "linux": "" },
    "./.config/ranger/rc.conf": { "linux": "" },
    "./.config/ranger/rifle.conf": { "linux": "" },
    "./.config/ranger/scope.sh": { "linux": "" },
    "./.config/rofi/config.rasi": { "linux": "" },
    "./.config/rofi/themes/Kokonai.rasi": { "linux": "" },
    "./.config/systemd/user/i3status-additional.service": { "linux": "" },
    "./.config/systemd/user/ssh-agent.service": { "linux": "" },
    "./.config/systemd/user/warn-battery.service": { "linux": "" },
    "./.config/yt-dlp.conf": { "linux": "" },

    "./.config/Code/User/keybindings.json.j2": {
        "windows": "AppData/Roaming/Code/User/keybindings.json",
        "linux": "./.config/Code - OSS/User/keybindings.json"
    },
    "./.config/Code/User/settings.json.j2": {
        "windows": "AppData/Roaming/Code/User/settings.json",
        "linux": "./.config/Code - OSS/User/settings.json"
    },
    "./.config/Code/User/tasks.json": {
        "windows": "AppData/Roaming/Code/User/tasks.json",
        "linux": "./.config/Code - OSS/User/tasks.json"
    },

    "./.githooks/pre-commit-jenkins-lint": "",
    "./.githooks/prepare-commit-msg-common-end": "",
    "./.githooks/prepare-commit-msg-common-start": "",
    "./.githooks/prepare-commit-msg-gerrit-auto-change-id": "",

    "./.local/bin/#": "",
    "./.local/bin/add-breakpoint": { "linux": "" },
    "./.local/bin/agt": "",
    "./.local/bin/agt-all-branches": "",
    "./.local/bin/ahk-ezautocompl.ahk": { "windows": "" },
    "./.local/bin/ansible-lsp": "",
    "./.local/bin/ansiclean": "",
    "./.local/bin/arch-pkgbuild-clone": "",
    "./.local/bin/asc": "",
    "./.local/bin/aurss": { "linux": "" },
    "./.local/bin/bazel-list": "",
    "./.local/bin/bell": "",
    "./.local/bin/bitee": "",
    "./.local/bin/bk": "",
    "./.local/bin/bkm": "",
    "./.local/bin/blank-screen": "",
    "./.local/bin/cb": "",
    "./.local/bin/cb-img": "",
    "./.local/bin/cb-img-jpg": "",
    "./.local/bin/cbwatch": "",
    "./.local/bin/certificate-show-fingerprint": "",
    "./.local/bin/cfp": { "linux": "" },
    "./.local/bin/check-if-tcp-port-is-open": "",
    "./.local/bin/check-sh-dash": "",
    "./.local/bin/check-system": "",
    "./.local/bin/clean-zsh-dirstack": "",
    "./.local/bin/clipdiff": "",
    "./.local/bin/cmake-quickbuild": "",
    "./.local/bin/copy-primary-sel-to-clipboard": "",
    "./.local/bin/cpwd": "",
    "./.local/bin/dbus-list-all-services": "",
    "./.local/bin/dcot": "",
    "./.local/bin/debug-caller": { "linux": "" },
    "./.local/bin/drb": "",
    "./.local/bin/edit-clipboard": "",
    "./.local/bin/edit-from-base64-arg": "",
    "./.local/bin/ferret-display": "",
    "./.local/bin/ffclip": "",
    "./.local/bin/ffcut": "",
    "./.local/bin/ffmpeg-to-gif": "",
    "./.local/bin/ffsmol": "",
    "./.local/bin/ffsmoltwo": "",
    "./.local/bin/file-changed": "",
    "./.local/bin/find-upwards": "",
    "./.local/bin/focuswindow": { "linux": "" },
    "./.local/bin/font-lookup-character": { "linux": "" },
    "./.local/bin/forever": "",
    "./.local/bin/fstack": { "linux": "" },
    "./.local/bin/gerrit-change-id": "",
    "./.local/bin/git-abort": "",
    "./.local/bin/git-cleanup-local-remote-files": "",
    "./.local/bin/git-continue": "",
    "./.local/bin/git-copy-current-revision": "",
    "./.local/bin/git-create-tag": "",
    "./.local/bin/git-current-branch": "",
    "./.local/bin/git-current-command": "",
    "./.local/bin/git-current-commit": "",
    "./.local/bin/git-deinit-all-submodules": "",
    "./.local/bin/git-delete-remote-branch": "",
    "./.local/bin/git-delete-tag": "",
    "./.local/bin/git-do-for-all-branches": "",
    "./.local/bin/git-drop": "",
    "./.local/bin/git-find-commit-by-message": "",
    "./.local/bin/git-go-back": "",
    "./.local/bin/git-grep-logs": "",
    "./.local/bin/git-has-changes": "",
    "./.local/bin/git-hookman": "",
    "./.local/bin/git-is-branch-same-as-tracking": "",
    "./.local/bin/git-is-tracked": "",
    "./.local/bin/git-list-changed-files-in-commit": "",
    "./.local/bin/git-rebase-noninteractive": "",
    "./.local/bin/git-rebase-noninteractive-single": "",
    "./.local/bin/git-remote-copy-url": "",
    "./.local/bin/git-remote-edit-url": "",
    "./.local/bin/git-reset-file": "",
    "./.local/bin/git-reset-submodule": "",
    "./.local/bin/git-reset-to-tracked": "",
    "./.local/bin/git-review-forced": "",
    "./.local/bin/git-search-all-branches": "",
    "./.local/bin/git-show-me-what-you-got": "",
    "./.local/bin/git-show-toplevel-name": "",
    "./.local/bin/git-show-toplevel-path": "",
    "./.local/bin/git-stage-all": "",
    "./.local/bin/git-stage-all-unstaged-changes": "",
    "./.local/bin/git-submodule-apply": "",
    "./.local/bin/git-submodule-remove": "",
    "./.local/bin/git-undo-amend": "",
    "./.local/bin/git-undo-keep-changes": "",
    "./.local/bin/git-undo-last-commit-but-keep-changes": "",
    "./.local/bin/git-undo-specific-hunks-but-keep-changes": "",
    "./.local/bin/git-unstage": "",
    "./.local/bin/gitm": "",
    "./.local/bin/gitpseudfuse": "",
    "./.local/bin/gitr": "",
    "./.local/bin/gitsup": "",
    "./.local/bin/gitup": "",
    "./.local/bin/grr": "",
    "./.local/bin/i3-chrome-open-url-in-mpv": { "linux": "" },
    "./.local/bin/i3-ctrlc": { "linux": "" },
    "./.local/bin/i3-ctrlp": { "linux": "" },
    "./.local/bin/i3-edit-mark": { "linux": "" },
    "./.local/bin/i3-focus-mark": "",
    "./.local/bin/i3-make-sticky": { "linux": "" },
    "./.local/bin/i3-swap-workspaces": { "linux": "" },
    "./.local/bin/i3-type-mark": { "linux": "" },
    "./.local/bin/install-local-bin": { "linux": "" },
    "./.local/bin/internet-wait-for": "",
    "./.local/bin/jenkins-listen-job": "",
    "./.local/bin/jinja2": "",
    "./.local/bin/json2msgpack": "",
    "./.local/bin/last-local-bins": "",
    "./.local/bin/lastdl": "",
    "./.local/bin/lastfile": "",
    "./.local/bin/mark-code": "",
    "./.local/bin/meson-quickbuild": "",
    "./.local/bin/mmbr": "",
    "./.local/bin/music-to-youtube": "",
    "./.local/bin/music-youtube-dl": "",
    "./.local/bin/mvn-download-all-dependencies": "",
    "./.local/bin/mvn-fetch": "",
    "./.local/bin/notify-run": "",
    "./.local/bin/npmis":  { "linux": "" },
    "./.local/bin/npmisd": { "linux": "" },
    "./.local/bin/num-set-desc": { "linux": "" },
    "./.local/bin/open-file-in-current-revision": "",
    "./.local/bin/parcellite-history": "",
    "./.local/bin/patch-create": "",
    "./.local/bin/polyfill-tree": "",
    "./.local/bin/pulseaudio-restart": "",
    "./.local/bin/pushtonumstash": "",
    "./.local/bin/q": "",
    "./.local/bin/random-port": "",
    "./.local/bin/rcb": "",
    "./.local/bin/re2sed": "",
    "./.local/bin/reconnman": { "linux": "" },
    "./.local/bin/record-screen": "",
    "./.local/bin/refresh-keyboard": { "linux": "" },
    "./.local/bin/refresh-keyring": "",
    "./.local/bin/remote-win-viewer": "",
    "./.local/bin/retab": "",
    "./.local/bin/riprep": "",
    "./.local/bin/ripsed": "",
    "./.local/bin/rnb": { "linux": "" },
    "./.local/bin/rsync-hosts": { "linux": "" },
    "./.local/bin/run-java": "",
    "./.local/bin/scan-brother": "",
    "./.local/bin/secret-lookup": "",
    "./.local/bin/secret-store": "",
    "./.local/bin/show-no-connman-con": { "linux": "" },
    "./.local/bin/showcqt": "",
    "./.local/bin/smart-context": { "linux": "" },
    "./.local/bin/sshhost": "",
    "./.local/bin/strip-final-newline": "",
    "./.local/bin/svimdiff": { "linux": "" },
    "./.local/bin/svnrootdir": "",
    "./.local/bin/syncy": "",
    "./.local/bin/t": "",
    "./.local/bin/termpopup": { "linux": "" },
    "./.local/bin/thu": { "linux": "" },
    "./.local/bin/thunar-kill-and-co": "",
    "./.local/bin/thuncb": "",
    "./.local/bin/tmux-oneshot": "",
    "./.local/bin/togglekb": "",
    "./.local/bin/track-execs": "",
    "./.local/bin/update-arch": { "linux": "" },
    "./.local/bin/update-arch-android": { "linux": "" },
    "./.local/bin/update-grub": "",
    "./.local/bin/update-numdots": "",
    "./.local/bin/update-ycm": "",
    "./.local/bin/vim-resave": "",
    "./.local/bin/vimdiff-first-with-rest": "",
    "./.local/bin/vimdirdiff": { "linux": "" },
    "./.local/bin/vimlns": "",
    "./.local/bin/vimp": "",
    "./.local/bin/vims": "",
    "./.local/bin/vtt-extract": "",
    "./.local/bin/warn-battery": "",
    "./.local/bin/watch-build": { "linux": "" },
    "./.local/bin/watch-go": { "linux": "" },
    "./.local/bin/watch-single": { "linux": "" },
    "./.local/bin/watch-vims": "",
    "./.local/bin/workspace-root": "",
    "./.local/bin/xprofile": { "linux": "" },
    "./.local/bin/xrandr-reset": "",
    "./.local/bin/xsleep": "",
    "./.local/bin/zoom-share-bar-hide": "",

    "./.local/bin_override/gimp": { "linux": "" },
    "./.local/bin_override/vimdiff": { "linux": "" },

    "./.qtcvimrc": "",
    "./.vim/colors/base16-kokonai.vim": { "linux": "" },
    "./.vim/templates/sh": "",
    "./.vimrc": "",
    "./.vsvimrc": { "windows": "" },

    "./.Xmodmap": { "linux": "" },
    "./.gitconfig.j2": "",
    "./.inputrc": "",
    "./.shellrc": "",
    "./.tigrc": { "linux": "", "windows": "./.config/tig/config" },
    "./.zshrc": { "linux": "" },

    "./.icon.jenkins.build.failed.png": "",
    "./.icon.jenkins.build.success.png": "",
}

if common.get_current_os() == None:
    raise NotImplementedError("Unsupported OS")
