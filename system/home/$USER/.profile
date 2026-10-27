export TERMINAL=nrxvt
export EDITOR=vim
export BROWSER=chromium
export PAGER=cat

# ripgrep
export RIPGREP_CONFIG_PATH="$HOME/.config/.ripgreprc"

# fzf
export FZF_DEFAULT_OPTS="--no-separator"

# ssh
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# nodejs
export PATH=$PATH:$HOME/.node_modules/bin
export NODE_OPTIONS="--enable-source-maps"

# go
export PATH=$PATH:$HOME/.go/bin
export GOPATH=$HOME/.go

# cargo
export PATH=$PATH:$HOME/.cargo/bin

# MAKEFLAGS
export MAKEFLAGS="$MAKEFLAGS -j4"

# ansible
export ANSIBLE_NOCOWS=1

# tig etc. (most ncurses)
export ESCDELAY=3
