import common

# sources {{{1
sources = {
    # <source>: <target> (empty means same as source)

    "./.config/.bazelrc": "./.bazelrc",
    "./.config/.ripgreprc": { "linux": "" },
    "./.config/alacritty/alacritty.yml.j2": { "linux": "", "windows": "AppData/Roaming/alacritty/alacritty.yml" },
    "./.config/dunst/dunstrc": { "linux": "" },
    "./.config/ezautocompl.yml": "",
    "./.config/fontconfig/fonts.conf": { "linux": "" },
    "./.config/fontconfig/no-subpixels-fonts.conf": { "linux": "" },
    "./.config/i3/config.j2": { "linux": "" },
    "./.config/llpp.conf": { "linux": "" },
    "./.config/mpv/config": { "linux": "", "windows": "~/scoop/apps/mpv/current/portable_config/config" },
    "./.config/mpv/input.conf": { "linux": "" },
    "./.config/nvim/autoload/airline/themes/base16_kokonai.vim": { "linux": "" },
    "./.config/nvim/colors/base16-kokonai.vim": { "linux": "" },
    "./.config/nvim/init.vim": "",
    "./.config/parcellite/parcelliterc": { "linux": "" },
    "./.config/ranger/rc.conf": { "linux": "" },
    "./.config/ranger/rifle.conf": { "linux": "" },
    "./.config/systemd/user/ssh-agent.service": { "linux": "" },

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

    "./.githooks/prepare-commit-msg-common-end": "",
    "./.githooks/prepare-commit-msg-common-start": "",
    "./.githooks/prepare-commit-msg-gerrit-auto-change-id": "",

    "./.local/bin/add-breakpoint": { "linux": "" },
    "./.local/bin/agt": "",
    "./.local/bin/ahk-ezautocompl.ahk": { "windows": "" },
    "./.local/bin/aurss": { "linux": "" },
    "./.local/bin/bell": "",
    "./.local/bin/cb": "",
    "./.local/bin/cfp": { "linux": "" },
    "./.local/bin/cmake-quickbuild": "",
    "./.local/bin/debug-caller": { "linux": "" },
    "./.local/bin/ffcut": "",
    "./.local/bin/ffsmol": "",
    "./.local/bin/find-upwards": "",
    "./.local/bin/focuswindow": { "linux": "" },
    "./.local/bin/font-lookup-character": { "linux": "" },
    "./.local/bin/fstack": { "linux": "" },
    "./.local/bin/git-drop": "",
    "./.local/bin/git-hookman": "",
    "./.local/bin/git-rebase-noninteractive": "",
    "./.local/bin/git-remote-copy-url": "",
    "./.local/bin/gitup": "",
    "./.local/bin/i3-chrome-open-url-in-mpv": { "linux": "" },
    "./.local/bin/i3-ctrlc": { "linux": "" },
    "./.local/bin/i3-ctrlp": { "linux": "" },
    "./.local/bin/i3-edit-mark": { "linux": "" },
    "./.local/bin/i3-make-sticky": { "linux": "" },
    "./.local/bin/i3-swap-workspaces": { "linux": "" },
    "./.local/bin/i3-type-mark": { "linux": "" },
    "./.local/bin/install-local-bin": { "linux": "" },
    "./.local/bin/lastdl": "",
    "./.local/bin/mark-code": "",
    "./.local/bin/music-to-youtube": "",
    "./.local/bin/music-youtube-dl": "",
    "./.local/bin/npmis":  { "linux": "" },
    "./.local/bin/npmisd": { "linux": "" },
    "./.local/bin/num-set-desc": { "linux": "" },
    "./.local/bin/pushtonumstash": "",
    "./.local/bin/rcb": "",
    "./.local/bin/reconnman": { "linux": "" },
    "./.local/bin/record-screen": "",
    "./.local/bin/refresh-keyboard": { "linux": "" },
    "./.local/bin/ripsed": "",
    "./.local/bin/rnb": { "linux": "" },
    "./.local/bin/show-no-connman-con": { "linux": "" },
    "./.local/bin/showcqt": "",
    "./.local/bin/smart-context": { "linux": "" },
    "./.local/bin/sshhost": "",
    "./.local/bin/svimdiff": { "linux": "" },
    "./.local/bin/svnrootdir": "",
    "./.local/bin/t": "",
    "./.local/bin/termpopup": { "linux": "" },
    "./.local/bin/thuncb": "",
    "./.local/bin/tmux-oneshot": "",
    "./.local/bin/togglekb": "",
    "./.local/bin/update-arch": { "linux": "" },
    "./.local/bin/update-arch-android": { "linux": "" },
    "./.local/bin/update-numdots": "",
    "./.local/bin/vimdirdiff": { "linux": "" },
    "./.local/bin/vtt-extract": "",
    "./.local/bin/watch-build": { "linux": "" },
    "./.local/bin/watch-go": { "linux": "" },
    "./.local/bin/watch-single": { "linux": "" },
    "./.local/bin/xprofile": { "linux": "" },

    "./.local/bin_override/gimp": { "linux": "" },

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
}

if common.get_current_os() == None:
    raise NotImplementedError("Unsupported OS")
