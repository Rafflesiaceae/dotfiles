export EDITOR=vim

# ripgrep
export RIPGREP_CONFIG_PATH="$HOME/.config/.ripgreprc"

# ssh
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# php
export PATH=$PATH:$HOME/.config/composer/vendor/bin

# nodejs
export PATH=$PATH:$HOME/.node_modules/bin
export npm_config_prefix=$HOME/.node_modules
export NODE_OPTIONS="--enable-source-maps"

# openresty
export PATH=$PATH:/opt/openresty/bin

# nim
export PATH=$PATH:$HOME/.nimble/bin

# go
export PATH=$PATH:$HOME/.go/bin
export GOPATH=$HOME/.go
export GOBIN=$HOME/.go/bin

# cargo
export PATH=$PATH:$HOME/.cargo/bin

# salt
alias salt=salt --config-dir=\$HOME/.salt
alias salt-minion=salt-minion --config-dir=\$HOME/.salt
