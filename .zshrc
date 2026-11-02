# functions
function \$() { $*; }

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

# cache autoload for 10min
autoload -Uz compinit
if [[ ! -e ~/.zcompdump || -n ~/.zcompdump(#qN.mm+9) ]]; then
    compinit
else
    compinit -C
fi

autoload -U colors && colors

## various
#  By default, if a command line contains a globbing expression which doesn't
#  match anything, Zsh will print the error message you're seeing, and not run
#  the command at all. - This disables it.
unsetopt nomatch

# Disable Job Completion Bell
unsetopt BEEP

## colors
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
dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
__cd_last_dirstack_dir() {
    [[ -d $dirstack[1] ]] && cd "$dirstack[1]"
}
if [[ -f $DIRSTACKFILE ]] && [[ "$SH_STARTOPTS" == *autodir:* ]]; then  # set $SH_STARTOPTS
    export SH_STARTOPTS="${SH_STARTOPTS//autodir:/}" # pop off autodir from SH_STARTOPTS
    __cd_last_dirstack_dir
elif [[ "$PWD" == "${HOME}/.lastdir" ]]; then  # explicit
    __cd_last_dirstack_dir
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
        if [[ ! -d "/tmp/zsh/" ]]; then
            mkdir -p "/tmp/zsh/"
        fi

        printf "%s" "$(rprompt_cmd)" > "/tmp/zsh/zsh_prompt_$$"

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
        parts+=("$(cat /tmp/zsh/zsh_prompt_$$ 2>/dev/null)")

        RPROMPT="$parts"

        # reset proc number
        ASYNC_PROC=0

        # redisplay
        zle && zle reset-prompt
        return 0
    fi

    # fired by the 60s timer
    emulate -L zsh
    [[ -n ${__ZSH_TITLE_CMDLINE-} ]] || return 0
    __title_set "🟠 ${__ZSH_TITLE_CMDLINE}"

  return 0
}
TRAPUSR1
function TRAPEXIT() {
    # cleanup async prompts
    [[ -f "/tmp/zsh/zsh_prompt_$$" ]] && rm "/tmp/zsh/zsh_prompt_$$"
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
PROMPT='$(show_last_exit_code) %n %{$fg[yellow]%}%~ %{$reset_color%}%% '
# }}}

__execute_precmds() {
    local fn
    for fn (precmd $precmd_functions); do
        (( $+functions[$fn] )) && $fn
    done
}

# {{{ fzf - cd to Dirstack <C-z>
cd_to_dirstack() {
    local newdir
    # Assign separately: `local x=$(...)` would mask fzf's exit status
    newdir=$(fzf < "$DIRSTACKFILE") || { zle .reset-prompt; return 1; }
    cd -- "$newdir"

    __execute_precmds

    # Only redraw the prompt for the new PWD; accepting the line would run
    # whatever the user has already typed in the buffer
    zle .reset-prompt
}
zle -N cd_to_dirstack{,}
bindkey '^Z' cd_to_dirstack
# }}}
# {{{ fzf - pick file below current dir <C-f>
pick_file() {
    # local newdir=$(/bin/ls -d1tr ~/* | tail -8 | fzf --tac --no-sort) || exit 1
    local file
    # Assign separately: `local x=$(...)` would mask fzf's exit status
    file=$(find * -type f | fzf) || { zle .reset-prompt; return 1; }
    LBUFFER+="$file"

    __execute_precmds

    zle .reset-prompt
}
zle      -N  pick_file{,}
bindkey '^F' pick_file
# }}}
# {{{ fzf - pick dir below current dir <C-d>
pick_dir() {
    local file
    # Assign separately: `local x=$(...)` would mask fzf's exit status
    file=$(find . -type d -maxdepth 1 | sed -E 's#^(\./)+##' | fzf) || { zle .reset-prompt; return 1; }
    LBUFFER+="$file"

    __execute_precmds

    zle .reset-prompt
}
zle      -N  pick_dir{,}
bindkey '^d' pick_dir
# }}}
# {{{ fzf - edit file <C-x>
edit_file() {
    local file="$(xclip -o)"

    # Expand ~/ to $HOME/
    [[ $file == '~/'* ]] && file="$HOME/${file#\~/}"

    vim -- "$file"
}
zle      -N  edit_file{,}
bindkey '^x' edit_file
# }}}
# {{{ fzf - most recent file from home <Alt-h>
most_recent_home() {
    local newdir
    # Assign separately: `local x=$(...)` would mask fzf's exit status
    newdir=$(/bin/ls -d1tr ~/* | tail -8 | fzf --tac --no-sort) || { zle .reset-prompt; return 1; }
    LBUFFER+="${newdir}"

    __execute_precmds

    zle .reset-prompt
}
zle      -N  most_recent_home{,}
bindkey '^[h' most_recent_home
# }}}
# {{{ fzf - list git branches <C-g>
list_git_branches_via_fzf() {
    local branch
    # Assign separately: `local x=$(...)` would mask fzf's exit status
    branch=$(git branch | awk -F ' +' '! /\(no branch\)/ {print $2}' | fzf) || { zle .reset-prompt; return 1; }
    LBUFFER+="$branch"
    zle .reset-prompt
}
zle -N list_git_branches_via_fzf{,}
bindkey '^G' list_git_branches_via_fzf
# }}}
# {{{ k8s - list pods <C-p>
list_k8s_pods_via_fzf() {
    local podline pod namespace
    # Assign separately: `local x=$(...)` would mask fzf's exit status
    podline=$(kubectl get pods --all-namespaces -o=custom-columns=NAME:.metadata.name,Namespace:.metadata.namespace | tail -n +2 | fzf) || { zle .reset-prompt; return 1; }
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
    local psout header choices choice container
    # Assign separately: `local x=$(...)` would mask the command's exit status
    psout=$(docker ps) || { zle .reset-prompt; return 1; }
    header=$(echo "$psout" | head -n 1)
    choices=$(echo "$psout" | tail -n +2)
    choice=$(echo "$choices" | fzf --header "$header") || { zle .reset-prompt; return 1; }
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
# {{{ edit first non-binary file in current buffer <F5>
edit_which_current_buffer() {
    emulate -L zsh
    local candidate encoding word
    local -a words order
    local -i i pos=1 start priority=0

    words=(${(z)BUFFER})

    # Find the word containing the cursor
    for (( i=1; i<=${#words}; i++ )); do
        word=${words[i]}

        # Locate the word in the original buffer
        while (( pos + ${#word} - 1 <= ${#BUFFER} )) &&
              [[ ${BUFFER[pos,pos+${#word}-1]} != "$word" ]]; do
            (( pos++ ))
        done

        start=pos-1  # ZLE cursor positions are zero-based

        if (( CURSOR >= start && CURSOR < start + ${#word} )); then
            priority=i
            break
        fi

        (( pos += ${#word} ))
    done

    # Cursor word first, then all other words left to right
    (( priority )) && order+=( $priority )
    for (( i=1; i<=${#words}; i++ )); do
        (( i == priority )) || order+=( $i )
    done

    for i in "${order[@]}"; do
        candidate=${(Q)words[i]}
        [[ $candidate == '~/'* ]] && candidate="$HOME/${candidate#\~/}"

        # Resolve executable names through PATH
        if [[ ! -f $candidate ]]; then
            candidate=$(whence -p -- "$candidate" 2>/dev/null) || continue
        fi

        [[ -f $candidate ]] || continue

        # Skip binary files
        encoding=$(file -Lb --mime-encoding -- "$candidate") || continue
        [[ $encoding == binary ]] && continue

        # Resolve symlinks before editing
        candidate=$(realpath -- "$candidate") || continue

        "$EDITOR" "$candidate"
        return
    done
}
zle -N edit_which_current_buffer
bindkey '^[[15~' edit_which_current_buffer # F5
# }}}
# {{{ edit file from xsel primary <F4>
edit_xsel_primary() {
     termpopup --fullterm --no-wait -- "cd" "$PWD" ";" "$EDITOR" "$(xsel -o)" ";" "\$SHELL"
}
zle -N edit_xsel_primary
bindkey '^[[14~' edit_xsel_primary # F4
# }}}
# {{{ set title
# --- terminal title: idle/command, and show failure title if last exit != 0 ---

# Customize this if you want:
typeset -g ZSH_TITLE_IDLE=${ZSH_TITLE_IDLE:-zsh}
typeset -g ZSH_TITLE_FAIL=${ZSH_TITLE_FAIL:-zsh}   # shown when last command exited non-zero
typeset -g ZSH_TITLE_MAXLEN=${ZSH_TITLE_MAXLEN:-120}

# Set terminal/window title (works for most xterm-compatible terminals, including in tmux/screen).
__title_set() {
  emulate -L zsh
  local title="$1"

  # keep it one line + reasonably short
  title=${title//$'\n'/ }
  title=${title//$'\r'/ }
  title=${title//$'\t'/ }
  (( ${#title} > ZSH_TITLE_MAXLEN )) && title="${title[1,ZSH_TITLE_MAXLEN-1]}…"

  if [[ -n ${TMUX-} ]]; then
    # tmux passthrough
    print -n -- "\ePtmux;\e\e]0;${title}\a\e\\"
  elif [[ $TERM == screen* || $TERM == tmux* ]]; then
    # GNU screen passthrough
    print -n -- "\eP\e]0;${title}\a\e\\"
  else
    # direct OSC (xterm et al.)
    print -n -- "\e]0;${title}\a"
  fi
}

__title_idle() {
  local st=$?   # exit status of the last command (as seen by precmd)
  emulate -L zsh
  if (( st != 0 && st != 130 )); then
    __title_set "🔴 ${ZSH_TITLE_FAIL}"
  else
    __title_set "🟢 ${ZSH_TITLE_IDLE}"
  fi
}

__title_preexec() {
  emulate -L zsh
  local cmdline="$1"
  __title_set "🟡 $cmdline"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd  __title_idle     # runs when zsh is ready for input (after command finished)
add-zsh-hook preexec __title_preexec  # runs right before executing a command

# Set initial title on shell startup
__title_idle
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

# Deduplicate current PATH:
typeset -U path PATH

# @TODO clean local functions here bleeding into interactive shell context/scope

true # or else one-liner conditionals bleed their status into last_exit_code
