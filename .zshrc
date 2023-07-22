# functions
function \$() { $*; }
function f() { # colored find / searches current tree recursively
    find . -iregex ".*$@" -printf '%P\0' 2> >(grep -v "Permission denied" ) | xargs -r0 ls --color=auto -1d
    # declare -A lscolormap

    # local lscolorsplits=("${(@s/:/)LS_COLORS}") # split LS_COLORS by ':'
    # for foo in "${a[@]}"; do
    #     lscolormap[]
    # done


    # while IFS=':' read -A args; do
    #   echo "${args[1]}"
    # done < "$LS_COLORS"

    # export IFS=":"
    # for word in "$LS_COLORS"; do
    #   echo "1"
    # done

    # find . -iregex ".*$@" 2> >(grep -v "Permission denied" ) 1> >(while IFS='$\n' read -r line;  do; ls --color=auto -1d "$line"; done; )
}

function cdgit() {
    cd "$(git rev-parse --show-toplevel)"
}

function pyselect2() {
    if [[ "$PATH" =~ "bin_override_py2" ]]; then
        echo "Already set python2 as default"
        echo "TODO: switch to python3"
    else
        export PATH="$HOME/.local/bin_override_py2/:$PATH"
    fi
}

## basic
bindkey -e # emacs default binds
REPORTTIME=5 # show time if command takes longer than 5 seconds

fpath=("$HOME/.zsh" $fpath)

autoload -Uz compinit && compinit
autoload -U colors && colors

## various
#  By default, if a command line contains a globbing expression which doesn't
#  match anything, Zsh will print the error message you're seeing, and not run
#  the command at all. - This disables it.
unsetopt nomatch

## colors
# {{{ base16 colorscheme - kokonai
# Base16 Kokonai - Shell color setup script

if [ "${TERM%%-*}" = 'linux' ]; then
    # This script doesn't support linux console (use 'vconsole' template instead)
    return 2>/dev/null || exit 0
fi

color00="27/28/22" # Base 00 - Black
color01="FF/45/35" # Base 08 - Red
color02="a6/e2/2e" # Base 0B - Green
color03="FD/D1/02" # Base 0A - Yellow
color04="33/B9/F3" # Base 0D - Blue
color05="ae/81/ff" # Base 0E - Magenta
color06="73/E6/E6" # Base 0C - Cyan
color07="f8/f8/f2" # Base 05 - White
color08="99/94/7B" # Base 03 - Bright Black
color09=$color01 # Base 08 - Bright Red
color10=$color02 # Base 0B - Bright Green
color11=$color03 # Base 0A - Bright Yellow
color12=$color04 # Base 0D - Bright Blue
color13=$color05 # Base 0E - Bright Magenta
color14=$color06 # Base 0C - Bright Cyan
color15="f9/f8/f5" # Base 07 - Bright White
color16="fd/97/1f" # Base 09
color17="F3/55/A1" # Base 0F
color18="38/38/30" # Base 01
color19="49/48/3e" # Base 02
color20="a5/9f/85" # Base 04
color21="f5/f4/f1" # Base 06
color_foreground="f8/f8/f2" # Base 05
color_background="27/28/22" # Base 00
color_cursor="f8/f8/f2" # Base 05

if [ -n "$TMUX" ]; then
  # tell tmux to pass the escape sequences through
  # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
  printf_template="\033Ptmux;\033\033]4;%d;rgb:%s\007\033\\"
  printf_template_var="\033Ptmux;\033\033]%d;rgb:%s\007\033\\"
elif [ "${TERM%%-*}" = "screen" ]; then
  # GNU screen (screen, screen-256color, screen-256color-bce)
  printf_template="\033P\033]4;%d;rgb:%s\007\033\\"
  printf_template_var="\033P\033]%d;rgb:%s\007\033\\"
else
  printf_template="\033]4;%d;rgb:%s\033\\"
  printf_template_var="\033]%d;rgb:%s\033\\"
fi

# 16 color space
printf $printf_template 0  $color00
printf $printf_template 1  $color01
printf $printf_template 2  $color02
printf $printf_template 3  $color03
printf $printf_template 4  $color04
printf $printf_template 5  $color05
printf $printf_template 6  $color06
printf $printf_template 7  $color07
printf $printf_template 8  $color08
printf $printf_template 9  $color09
printf $printf_template 10 $color10
printf $printf_template 11 $color11
printf $printf_template 12 $color12
printf $printf_template 13 $color13
printf $printf_template 14 $color14
printf $printf_template 15 $color15

# 256 color space
printf $printf_template 16 $color16
printf $printf_template 17 $color17
printf $printf_template 18 $color18
printf $printf_template 19 $color19
printf $printf_template 20 $color20
printf $printf_template 21 $color21

# foreground / background / cursor color
printf $printf_template_var 10 $color_foreground
printf $printf_template_var 11 $color_background
printf $printf_template_var 12 $color_cursor

# clean up
unset printf_template
unset printf_template_var
unset color00
unset color01
unset color02
unset color03
unset color04
unset color05
unset color06
unset color07
unset color08
unset color09
unset color10
unset color11
unset color12
unset color13
unset color14
unset color15
unset color16
unset color17
unset color18
unset color19
unset color20
unset color21
unset color_foreground
unset color_background
unset color_cursor
# }}}
# {{{ custom man colorscheme
man() {
    env \
        LESS_TERMCAP_mb=$'\E[1;5;48;5;31m' \
        LESS_TERMCAP_md=$'\E[01;38;5;16m' \
        LESS_TERMCAP_me=$'\E[0m' \
        LESS_TERMCAP_se=$'\E[0m' \
        LESS_TERMCAP_so=$'\E[00;38;5;15m' \
        LESS_TERMCAP_ue=$'\E[0m' \
        LESS_TERMCAP_us=$'\E[04;38;5;00;33m' \
        man $*
    }
# }}}
# {{{ LS_COLORS
# to setup:
# $ git clone "https://github.com/trapd00r/LS_COLORS.git" "~/.lsdcolors"
[[ -f "$HOME/.lsdcolors/LS_COLORS" ]] && eval $(dircolors -b "$HOME/.lsdcolors/LS_COLORS")
# }}}

## basic
# {{{ history
HISTFILE=~/.histfile # where to save history to disk
HISTSIZE=10000        # how many lines of history to keep in memory
SAVEHIST=10000        # number of history entries to save to disk

setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt incappendhistory       # immediately append to the history file, not just when a term is killed
# }}}
# {{{ autopushd
setopt autopushd pushdsilent pushdtohome

## Remove duplicate entries
setopt pushdignoredups

## This reverts the +/- operators.
setopt pushdminus
# }}}
# {{{ dirstack
DIRSTACKSIZE=200
DIRSTACKFILE="$HOME/.cache/zsh/dirs"
if [[ -f $DIRSTACKFILE ]] && [[ $#dirstack -eq 0 ]]; then
    dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
    if [[ "$SH_STARTOPTS" == *autodir:* ]]; then
        export SH_STARTOPTS="${SH_STARTOPTS//autodir:/}" # pop off autodir from SH_STARTOPTS
        [[ -d $dirstack[1] ]] && cd "$dirstack[1]"
    fi
fi

chpwd() { print -l $PWD ${(u)dirstack} >$DIRSTACKFILE; }
# }}}

## prompt/rprompt
# {{{ RPROMPT
local zsh_git_prompt=$HOME/.zsh/zsh-git-prompt/zshrc.sh
local has_zsh_git_prompt=
command -v gitusers &>/dev/null && has_zsh_git_prompt=1
function rprompt_cmd() {
    [[ $has_zsh_git_prompt ]] && echo "$(gitusers -p)"
}

ASYNC_PROC=0
function precmd() {
    function async() {
        # save to temp file
        printf "%s" "$(rprompt_cmd)" > "/tmp/zsh_prompt_$$"

        # signal parent
        kill -s USR1 $$
    }

    # do not clear RPROMPT, let it persist

    # kill child if necessary
    if [[ "${ASYNC_PROC}" != 0 ]]; then
        kill -s HUP $ASYNC_PROC >/dev/null 2>&1 || :
    fi

    # start background computation
    async &!
    ASYNC_PROC=$!
}

function TRAPUSR1() {
    if [[ $has_zsh_git_prompt ]]; then
        local parts

        parts+=("$(date +"%T")") # date

        # conda-env
        if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
            parts+=('%B'"${CONDA_DEFAULT_ENV:0:28}"'%b')
        fi

        # rprompt_cmd
        parts+=("$(cat /tmp/zsh_prompt_$$ 2>/dev/null)")

        RPROMPT="$parts"

        # reset proc number
        ASYNC_PROC=0

        # redisplay
        zle && zle reset-prompt
    fi
}
TRAPUSR1
function TRAPEXIT() {
    # cleanup async prompts
    [[ -f "/tmp/zsh_prompt_$$" ]] && rm "/tmp/zsh_prompt_$$"
}
# }}}
# {{{ PROMPT: Show last exit-code
function show_last_exit_code() {
    local last_exit_code=$?
    if [[ $last_exit_code -eq 0 ]]; then
        echo "%{$bg[blue]%}  %{$reset_color%}%{$fg[blue]%}"
    elif [[ $last_exit_code -eq 127 ]]; then                                          # unknown command
        echo "%{$bg[yellow]%}  %{$reset_color%}%{$fg[yellow]%}"
    elif [[ $last_exit_code -eq 255 ]]; then                                          # display 255 as -1
        echo "%{$bg[red]%}%{$fg[black]%}-1%{$reset_color%}%{$fg[red]%}"
    elif [[ $last_exit_code -lt 10 ]]; then
        echo "%{$bg[red]%}%{$fg[black]%}$last_exit_code %{$reset_color%}%{$fg[red]%}"
    elif [[ $last_exit_code -lt 100 ]]; then
        echo "%{$bg[red]%}%{$fg[black]%}$last_exit_code%{$reset_color%}%{$fg[red]%}"
    elif [[ $last_exit_code -gt 10 ]]; then
        echo "%{$bg[red]%}%{$fg[black]%}>>%{$reset_color%}%{$fg[red]%}"
    fi
}

setopt PROMPT_SUBST
PROMPT='$(show_last_exit_code) %n %{$fg[yellow]%}%~ %{$reset_color%}%% '
# }}}

__execute_precmds() {
    local fn
    for fn (precmd $precmd_functions); do
        (( $+functions[$fn] )) && $fn
    done
}

# {{{ fzf - cd to Dirstack <C-z>
cd_to_dirstack() {
    local newdir=$(cat "$HOME/.cache/zsh/dirs" | fzf) || exit 1
    cd "$newdir"

    __execute_precmds()

    zle .reset-prompt
    zle .accept-line
}
zle -N cd_to_dirstack{,}
bindkey '^Z' cd_to_dirstack
# }}}
# {{{ fzf - pick file below current dir <C-f>
pick_file() {
    # local newdir=$(/bin/ls -d1tr ~/* | tail -8 | fzf --tac --no-sort) || exit 1
    local file=$(find * -type f | fzf) || exit 1
    LBUFFER+="$file"

    __execute_precmds()

    zle .reset-prompt
}
zle      -N  pick_file{,}
bindkey '^F' pick_file
# }}}
# {{{ fzf - most recent file from home <Alt-h>
most_recent_home() {
    local newdir=$(/bin/ls -d1tr ~/* | tail -8 | fzf --tac --no-sort) || exit 1
    LBUFFER+="${newdir}"

    __execute_precmds()

    zle .reset-prompt
}
zle      -N  most_recent_home{,}
bindkey '^[h' most_recent_home
# }}}
# {{{ fzf - list git branches <C-g>
list_git_branches_via_fzf() {
    local branch=$(git branch | awk -F ' +' '! /\(no branch\)/ {print $2}' | fzf) || exit 1
    LBUFFER+="$branch"
    zle .reset-prompt
}
zle -N list_git_branches_via_fzf{,}
bindkey '^G' list_git_branches_via_fzf
# }}}
# {{{ k8s - list pods <C-p>
list_k8s_pods_via_fzf() {
    local podline=$(kubectl get pods --all-namespaces -o=custom-columns=NAME:.metadata.name,Namespace:.metadata.namespace | tail -n +2 | fzf) || exit 1
    pod=$(echo "$podline" | awk '{ print $1 }')
    namespace=$(echo "$podline" | awk '{ print $2 }')
    LBUFFER+="-n $namespace $pod"
    zle .reset-prompt
}
zle -N list_k8s_pods_via_fzf{,}
bindkey '^[p' list_k8s_pods_via_fzf
# }}}
# {{{ docker - list containers <Alt-d>
list_docker_containers_via_fzf() {
    local psout=$(docker ps) || exit 1
    local header=$(echo "$psout" | head -n 1)
    local choices=$(echo "$psout" | tail -n +2)
    local choice=$(echo "$choices" | fzf --header "$header") || exit 1
    container=$(echo "$choice" | awk '{ print $1 }')
    LBUFFER+="$container"
    zle .reset-prompt
}
zle -N list_docker_containers_via_fzf{,}
bindkey '^[d' list_docker_containers_via_fzf
# }}}
# {{{ show vi-mode
# function zle-line-init zle-keymap-select {
#     RPS1="${${KEYMAP/vicmd/-- NORMAL --}/(main|viins)/-- INSERT --}"
#     RPS2=$RPS1
#     zle reset-prompt
# }

# zle -N zle-line-init
# zle -N zle-keymap-select
# }}}
# {{{ expand command line with <C-v>
expand_command_line() {
    cbcontents=$(xclip -o 2>/dev/null)
    BUFFER="${BUFFER//\%\%/$cbcontents}"
}
zle -N expand_command_line
bindkey "^v" expand_command_line
# }}}
# {{{ edit command line with <C-k>
autoload edit-command-line; zle -N edit-command-line
bindkey "^k" edit-command-line
# }}}
# {{{ edit which current buffer <F5>
edit_which_current_buffer() {
    trimmed_buffer=$(echo "$BUFFER" | awk '{$1=$1;print}') # trim string
    file=$(which "$trimmed_buffer")
    if [[ -L "$file" ]]; then # resolve symlinks
        file=$(readlink "$file")
    fi
    "$EDITOR" "$file"
}
zle -N edit_which_current_buffer
bindkey '^[[15~' edit_which_current_buffer # F5
# }}}
# {{{ edit file from xsel primary <F4>
edit_xsel_primary() {
     termpopup --fullterm --no-wait -- "cd" "$PWD" ";" "$EDITOR" "$(xsel -o)"
}
zle -N edit_xsel_primary
bindkey '^[[14~' edit_xsel_primary # F4
# }}}

## autocompletion
# basic autocomplete settings {{{
autoload -U bashcompinit
bashcompinit
# }}}
# {{{ autocomplete ssh config hosts
h=()
if [[ -r ~/.ssh/config ]]; then
    h=($h ${${${(@M)${(f)"$(cat ~/.ssh/config)"}:#Host *}#Host }:#*[*?]*})
fi
# if [[ -r ~/.ssh/known_hosts ]]; then
#   h=($h ${${${(f)"$(cat ~/.ssh/known_hosts{,2} || true)"}%%\ *}%%,*}) 2>/dev/null
# fi
if [[ $#h -gt 0 ]]; then
    zstyle ':completion:*:ssh:*' hosts $h
    zstyle ':completion:*:slogin:*' hosts $h
fi
# }}}
# autocomplete python argcomplete {{{
# $ register-python-argcomplete {{{
# Run something, muting output or redirecting it to the debug stream
# depending on the value of _ARC_DEBUG.
# If ARGCOMPLETE_USE_TEMPFILES is set, use tempfiles for IPC.
__python_argcomplete_run() {
    if [[ -z "${ARGCOMPLETE_USE_TEMPFILES-}" ]]; then
        __python_argcomplete_run_inner "$@"
        return
    fi
    local tmpfile="$(mktemp)"
    _ARGCOMPLETE_STDOUT_FILENAME="$tmpfile" __python_argcomplete_run_inner "$@"
    local code=$?
    cat "$tmpfile"
    rm "$tmpfile"
    return $code
}

__python_argcomplete_run_inner() {
    if [[ -z "${_ARC_DEBUG-}" ]]; then
        "$@" 8>&1 9>&2 1>/dev/null 2>&1
    else
        "$@" 8>&1 9>&2 1>&9 2>&1
    fi
}

_python_argcomplete() {
    local IFS=$'\013'
    local SUPPRESS_SPACE=0
    if compopt +o nospace 2> /dev/null; then
        SUPPRESS_SPACE=1
    fi
    COMPREPLY=( $(IFS="$IFS" \
                  COMP_LINE="$COMP_LINE" \
                  COMP_POINT="$COMP_POINT" \
                  COMP_TYPE="$COMP_TYPE" \
                  _ARGCOMPLETE_COMP_WORDBREAKS="$COMP_WORDBREAKS" \
                  _ARGCOMPLETE=1 \
                  _ARGCOMPLETE_SUPPRESS_SPACE=$SUPPRESS_SPACE \
                  __python_argcomplete_run "$1") )
    if [[ $? != 0 ]]; then
        unset COMPREPLY
    elif [[ $SUPPRESS_SPACE == 1 ]] && [[ "${COMPREPLY-}" =~ [=/:]$ ]]; then
        compopt -o nospace
    fi
}
# }}}

function argcomplete() {
    complete -o nospace -o default -o bashdefault -F _python_argcomplete $*
}

# manage your list of argcomplete supported commands in your ~/.zshrc.local with entries like this:
# argcomplete "my-cool-script" "my-other-cool-script"

# }}}
# autocomplete q {{{
complete -C "q --list" q
# }}}


# settings shared between different shells
[ -f ~/.shellrc ] && source ~/.shellrc

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# for local zshrc settings outside of dotfiles
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# @TODO clean local functions here bleeding into interactive shell context/scope

true # or else one-liner conditionals bleed their status into last_exit_code
