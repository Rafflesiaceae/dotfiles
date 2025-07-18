import common

# sources {{{1
sources = {
    # <source>: <target> (empty means same as source)
    "./.config/.bazelrc": "./.bazelrc",
    "./.config/.ripgreprc": {"linux": ""},
    "./.config/.yamlfmt": "",
    "./.config/Thunar/uca.xml": {"linux": ""},
    "./.config/alacritty/alacritty.yml.j2": {
        "linux": "",
        "windows": "AppData/Roaming/alacritty/alacritty.yml",
    },
    "./.config/dunst/dunstrc": {"linux": ""},
    "./.config/ezautocompl.yml": "",
    "./.config/fontconfig/fonts.conf": {"linux": ""},
    "./.config/fontconfig/no-subpixels-fonts.conf": {"linux": ""},
    "./.config/gdb-simple.gdb": {"linux": ""},
    "./.config/i3/config.j2": {"linux": ""},
    "./.config/llpp.conf": {"linux": ""},
    "./.config/mpv/config": {
        "linux": "",
        "windows": "~/scoop/apps/mpv/current/portable_config/config",
    },
    "./.config/mpv/input.conf": {"linux": ""},
    "./.config/mpv/scripts/global-vol.lua": "",
    "./.config/mpv/scripts/time-management.lua": "",
    "./.config/nvim/.editorconfig": "",
    "./.config/nvim/autoload/airline/themes/base16_kokonai.vim": {"linux": ""},
    "./.config/nvim/colors/base16-kokonai.vim": {"linux": ""},
    "./.config/nvim/init.vim": "",
    "./.config/nvim/lua/treesitter-nu.lua": "",
    "./.config/parcellite/parcelliterc": {"linux": ""},
    "./.config/ranger/rc.conf": {"linux": ""},
    "./.config/ranger/rifle.conf": {"linux": ""},
    "./.config/ranger/scope.sh": {"linux": ""},
    "./.config/rofi/config.rasi": {"linux": ""},
    "./.config/rofi/themes/Kokonai.rasi": {"linux": ""},
    "./.config/systemd/user/i3status-additional.service": {"linux": ""},
    "./.config/systemd/user/ssh-agent.service": {"linux": ""},
    "./.config/systemd/user/warn-battery.service": {"linux": ""},
    "./.config/yt-dlp.conf": {"linux": ""},
    "./.config/Code/User/keybindings.json.j2": {
        "windows": "AppData/Roaming/Code/User/keybindings.json",
        "linux": "./.config/Code - OSS/User/keybindings.json",
    },
    "./.config/Code/User/settings.json.j2": {
        "windows": "AppData/Roaming/Code/User/settings.json",
        "linux": "./.config/Code - OSS/User/settings.json",
    },
    "./.config/Code/User/tasks.json": {
        "windows": "AppData/Roaming/Code/User/tasks.json",
        "linux": "./.config/Code - OSS/User/tasks.json",
    },
    "./.githooks/pre-commit-jenkins-lint": "",
    "./.githooks/prepare-commit-msg-common-end": "",
    "./.githooks/prepare-commit-msg-common-start": "",
    "./.githooks/prepare-commit-msg-gerrit-auto-change-id": "",
    "./.local/bin/#": "",
    "./.local/bin/add-breakpoint": {"linux": ""},
    "./.local/bin/agt": "",
    "./.local/bin/agt-all-branches": "",
    "./.local/bin/ahk-ezautocompl.ahk": {"windows": ""},
    "./.local/bin/android-install-apk": "",
    "./.local/bin/android-sign-apk": "",
    "./.local/bin/ansible-lsp": "",
    "./.local/bin/ansiclean": "",
    "./.local/bin/arch-pkgbuild-clone": "",
    "./.local/bin/asc": "",
    "./.local/bin/aurss": {"linux": ""},
    "./.local/bin/autoformat-bash": "",
    "./.local/bin/autoformat-c": "",
    "./.local/bin/autoformat-css": "",
    "./.local/bin/autoformat-go": "",
    "./.local/bin/autoformat-hcl": "",
    "./.local/bin/autoformat-html": "",
    "./.local/bin/autoformat-js": "",
    "./.local/bin/autoformat-json": "",
    "./.local/bin/autoformat-lua": "",
    "./.local/bin/autoformat-python": "",
    "./.local/bin/autoformat-sh": "",
    "./.local/bin/autoformat-ts": "",
    "./.local/bin/autoformat-xml": "",
    "./.local/bin/autoformat-yml": "",
    "./.local/bin/bazel-list": "",
    "./.local/bin/beary": "",
    "./.local/bin/bell": "",
    "./.local/bin/bindiff": "",
    "./.local/bin/bitee": "",
    "./.local/bin/bk": "",
    "./.local/bin/bkm": "",
    "./.local/bin/blank-screen": "",
    "./.local/bin/build": "",
    "./.local/bin/cb": "",
    "./.local/bin/cb-img": "",
    "./.local/bin/cb-img-jpg": "",
    "./.local/bin/cbwatch": "",
    "./.local/bin/certificate-show-fingerprint": "",
    "./.local/bin/cfp": {"linux": ""},
    "./.local/bin/check-if-tcp-port-is-open": "",
    "./.local/bin/check-sh-dash": "",
    "./.local/bin/check-system": "",
    "./.local/bin/check-xml": "",
    "./.local/bin/clean-zsh-dirstack": "",
    "./.local/bin/clipdiff": "",
    "./.local/bin/cmake-quickbuild": "",
    "./.local/bin/container-run": "",
    "./.local/bin/container-stop-all": "",
    "./.local/bin/copy-primary-sel-to-clipboard": "",
    "./.local/bin/cpwd": "",
    "./.local/bin/create-zip": "",
    "./.local/bin/dbus-list-all-services": "",
    "./.local/bin/dcot": "",
    "./.local/bin/debug-caller": {"linux": ""},
    "./.local/bin/docker-compose-open-volume": "",
    "./.local/bin/docker-run": "",
    "./.local/bin/drb": "",
    "./.local/bin/edit-clipboard": "",
    "./.local/bin/edit-current-urxvt-buffer": "",
    "./.local/bin/edit-current-urxvt-buffer-last-prompt": "",
    "./.local/bin/edit-from-base64-arg": "",
    "./.local/bin/ferret-display": "",
    "./.local/bin/ffclip": "",
    "./.local/bin/ffcut": "",
    "./.local/bin/ffextractaudio": "",
    "./.local/bin/ffmpeg-to-gif": "",
    "./.local/bin/ffmusicimagestill": "",
    "./.local/bin/ffsmol": "",
    "./.local/bin/ffsmoltwo": "",
    "./.local/bin/file-changed": "",
    "./.local/bin/find-upwards": "",
    "./.local/bin/focuswindow": {"linux": ""},
    "./.local/bin/font-lookup-character": {"linux": ""},
    "./.local/bin/forever": "",
    "./.local/bin/fstack": {"linux": ""},
    "./.local/bin/gdbr": "",
    "./.local/bin/gerrit-change-id": "",
    "./.local/bin/gh-apply-pr": "",
    "./.local/bin/git-abort": "",
    "./.local/bin/git-cleanup-local-remote-files": "",
    "./.local/bin/git-continue": "",
    "./.local/bin/git-copy-current-revision": "",
    "./.local/bin/git-create-patch": "",
    "./.local/bin/git-create-tag": "",
    "./.local/bin/git-current-branch": "",
    "./.local/bin/git-current-command": "",
    "./.local/bin/git-current-commit": "",
    "./.local/bin/git-debug-commitpush": "",
    "./.local/bin/git-deinit-all-submodules": "",
    "./.local/bin/git-delete-remote-branch": "",
    "./.local/bin/git-delete-tag": "",
    "./.local/bin/git-diff-view-meld-single-commit": "",
    "./.local/bin/git-do-for-all-branches": "",
    "./.local/bin/git-drop": "",
    "./.local/bin/git-edit-date": "",
    "./.local/bin/git-find-commit-by-message": "",
    "./.local/bin/git-first-commit": "",
    "./.local/bin/git-go-back": "",
    "./.local/bin/git-grep-branches": "",
    "./.local/bin/git-grep-logs": "",
    "./.local/bin/git-grep-stashes": "",
    "./.local/bin/git-has-changes": "",
    "./.local/bin/git-hookman": "",
    "./.local/bin/git-initial-commit": "",
    "./.local/bin/git-is-branch-same-as-tracking": "",
    "./.local/bin/git-is-tracked": "",
    "./.local/bin/git-list-changed-files-in-commit": "",
    "./.local/bin/git-rebase-noninteractive": "",
    "./.local/bin/git-rebase-noninteractive-single": "",
    "./.local/bin/git-rebase-upstream": "",
    "./.local/bin/git-remote-copy-url": "",
    "./.local/bin/git-remote-edit-url": "",
    "./.local/bin/git-reset-all-commits-of-current-branch-to-current-author": "",
    "./.local/bin/git-reset-file": "",
    "./.local/bin/git-reset-submodule": "",
    "./.local/bin/git-reset-to-tracked": "",
    "./.local/bin/git-review-forced": "",
    "./.local/bin/git-search-all-branches": "",
    "./.local/bin/git-show-me-what-you-got": "",
    "./.local/bin/git-show-toplevel-name": "",
    "./.local/bin/git-show-toplevel-path": "",
    "./.local/bin/git-split-into-remote-branch": "",
    "./.local/bin/git-stage-all": "",
    "./.local/bin/git-stage-all-unstaged-changes": "",
    "./.local/bin/git-submodule-apply": "",
    "./.local/bin/git-submodule-delete": "",
    "./.local/bin/git-submodule-remove": "",
    "./.local/bin/git-submodule-reset": "",
    "./.local/bin/git-undo-amend": "",
    "./.local/bin/git-undo-keep-changes": "",
    "./.local/bin/git-undo-last-commit-but-keep-changes": "",
    "./.local/bin/git-undo-specific-hunks-but-keep-changes": "",
    "./.local/bin/git-unstage": "",
    "./.local/bin/git-wip-commitpush": "",
    "./.local/bin/gitm": "",
    "./.local/bin/gitp": "",
    "./.local/bin/gitpf": "",
    "./.local/bin/gitpseudfuse": "",
    "./.local/bin/gitr": "",
    "./.local/bin/gits": "",
    "./.local/bin/gitsta": "",
    "./.local/bin/gitsup": "",
    "./.local/bin/gitup": "",
    "./.local/bin/grr": "",
    "./.local/bin/hex-to-decimal": "",
    "./.local/bin/i3-chrome-open-url-in-mpv": {"linux": ""},
    "./.local/bin/i3-ctrlc": {"linux": ""},
    "./.local/bin/i3-ctrlp": {"linux": ""},
    "./.local/bin/i3-edit-mark": {"linux": ""},
    "./.local/bin/i3-focus-mark": "",
    "./.local/bin/i3-make-sticky": {"linux": ""},
    "./.local/bin/i3-swap-workspaces": {"linux": ""},
    "./.local/bin/i3-type-mark": {"linux": ""},
    "./.local/bin/i3status-additional": "",
    "./.local/bin/inotify-who-hogs-my-watches": "",
    "./.local/bin/install-local-bin": {"linux": ""},
    "./.local/bin/internet-wait-for": "",
    "./.local/bin/jar-required-java-version": "",
    "./.local/bin/jenkins-listen-job": "",
    "./.local/bin/jinja2": "",
    "./.local/bin/json2msgpack": "",
    "./.local/bin/last-local-bins": "",
    "./.local/bin/lastdl": "",
    "./.local/bin/lastfile": "",
    "./.local/bin/loop-it": "",
    "./.local/bin/mark-code": "",
    "./.local/bin/meson-quickbuild": "",
    "./.local/bin/mmbr": "",
    "./.local/bin/mouse-slowdown": "",
    "./.local/bin/music-to-youtube": "",
    "./.local/bin/music-youtube-dl": "",
    "./.local/bin/mvn-download-all-dependencies": "",
    "./.local/bin/mvn-fetch": "",
    "./.local/bin/mvp": "",
    "./.local/bin/notify-run": "",
    "./.local/bin/npmis": {"linux": ""},
    "./.local/bin/npmisd": {"linux": ""},
    "./.local/bin/num-set-desc": {"linux": ""},
    "./.local/bin/open-file-in-current-revision": "",
    "./.local/bin/parcellite-history": "",
    "./.local/bin/patch-create": "",
    "./.local/bin/pdfify": "",
    "./.local/bin/polyfill-tree": "",
    "./.local/bin/posix-timestamp-milliseconds-to-date": "",
    "./.local/bin/pulseaudio-restart": "",
    "./.local/bin/pushtonumstash": "",
    "./.local/bin/q": "",
    "./.local/bin/raf-last-shell-output": "",
    "./.local/bin/raf-last-shell-output-extract": "",
    "./.local/bin/random-port": "",
    "./.local/bin/ranger-pick": "",
    "./.local/bin/rcb": "",
    "./.local/bin/re2sed": "",
    "./.local/bin/reconnman": {"linux": ""},
    "./.local/bin/record-screen": "",
    "./.local/bin/refresh-keyboard": {"linux": ""},
    "./.local/bin/refresh-keyring": "",
    "./.local/bin/remote-win-viewer": "",
    "./.local/bin/reset-vim": "",
    "./.local/bin/retab": "",
    "./.local/bin/riprep": "",
    "./.local/bin/ripsed": "",
    "./.local/bin/rnb": {"linux": ""},
    "./.local/bin/rpm-list-file-contents": "",
    "./.local/bin/rsync-hosts": {"linux": ""},
    "./.local/bin/run-java": "",
    "./.local/bin/scan-brother": "",
    "./.local/bin/secret-lookup": "",
    "./.local/bin/secret-store": "",
    "./.local/bin/show-no-connman-con": {"linux": ""},
    "./.local/bin/show-term-colors": "",
    "./.local/bin/showcqt": "",
    "./.local/bin/smart-context": {"linux": ""},
    "./.local/bin/ssh-add-all": "",
    "./.local/bin/sshhost": "",
    "./.local/bin/strip-ansi-escape-codes": "",
    "./.local/bin/strip-final-newline": "",
    "./.local/bin/svimdiff": {"linux": ""},
    "./.local/bin/svnrootdir": "",
    "./.local/bin/syncy": "",
    "./.local/bin/t": "",
    "./.local/bin/termpopup": {"linux": ""},
    "./.local/bin/thu": {"linux": ""},
    "./.local/bin/thunar-kill-and-co": "",
    "./.local/bin/thuncb": "",
    "./.local/bin/tmux-oneshot": "",
    "./.local/bin/tmux-run": "",
    "./.local/bin/togglekb": "",
    "./.local/bin/track-execs": "",
    "./.local/bin/tskl": "",
    "./.local/bin/update-arch": {"linux": ""},
    "./.local/bin/update-arch-android": {"linux": ""},
    "./.local/bin/update-grub": "",
    "./.local/bin/update-numdots": "",
    "./.local/bin/update-ycm": "",
    "./.local/bin/vim-pipe": "",
    "./.local/bin/vim-resave": "",
    "./.local/bin/vimdiff-first-with-rest": "",
    "./.local/bin/vimdirdiff": {"linux": ""},
    "./.local/bin/vimlns": "",
    "./.local/bin/vimp": "",
    "./.local/bin/vims": "",
    "./.local/bin/vtt-extract": "",
    "./.local/bin/wait-for-enter": "",
    "./.local/bin/warn-battery": "",
    "./.local/bin/watch-any": "",
    "./.local/bin/watch-build": {"linux": ""},
    "./.local/bin/watch-go": {"linux": ""},
    "./.local/bin/watch-single": {"linux": ""},
    "./.local/bin/watch-vims": "",
    "./.local/bin/workspace-root": "",
    "./.local/bin/xprofile": {"linux": ""},
    "./.local/bin/xrandr-reset": "",
    "./.local/bin/xsleep": "",
    "./.local/bin/zoom-share-bar-hide": "",
    "./.local/bin_override/gimp": {"linux": ""},
    "./.local/bin_override/vimdiff": {"linux": ""},
    "./.urxvt//ext/buffer-pipe": {"linux": ""},
    "./.qtcvimrc": "",
    "./.vim/colors/base16-kokonai.vim": {"linux": ""},
    "./.vim/templates/sh": "",
    "./.vimrc": "",
    "./.vsvimrc": {"windows": ""},
    "./.Xmodmap": {"linux": ""},
    "./.gitconfig.j2": "",
    "./.inputrc": "",
    "./.shellrc": "",
    "./.tigrc": {"linux": "", "windows": "./.config/tig/config"},
    "./.zshrc": {"linux": ""},
    "./.icon.jenkins.build.failed.png": "",
    "./.icon.jenkins.build.success.png": "",
}

if common.get_current_os() == None:
    raise NotImplementedError("Unsupported OS")
