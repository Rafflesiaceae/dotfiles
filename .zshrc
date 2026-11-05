# functions
function \$() { $*; }

function cdgit() {
    cd "$(git rev-parse --show-toplevel)"
}

## basic
bindkey -e # emacs default binds
REPORTTIME=5 # show time if command takes longer than 5 seconds

fpath=("$HOME/.zsh" $fpath)

# Only run the full (slow, security-checking) compinit when the dump is older
# than 20 hours, otherwise trust the cached dump via `compinit -C`
autoload -Uz compinit
() {
    # Glob qualifiers inside [[ ]] only work with extendedglob; keep it scoped
    setopt localoptions extendedglob
    if [[ -n ~/.zcompdump(#qN.mh-20) ]]; then
        compinit -C
    else
        compinit
        # compinit does not refresh the dump's mtime when nothing changed, so
        # without this the dump would count as stale forever
        touch ~/.zcompdump
        # Compile the dump so `compinit -C` can load the .zwc instead of
        # parsing the dump; must happen after the touch, as zsh ignores a
        # .zwc that is older than its source file
        zcompile ~/.zcompdump
    fi
}

autoload -U colors && colors
autoload -Uz add-zsh-hook # precmd/preexec hooks below

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

chpwd() {
    [[ -n $DIRSTACKFILE ]] || return 0
    print -l $PWD ${(u)dirstack} >$DIRSTACKFILE
}
# }}}

## prompt/rprompt
# {{{ RPROMPT
# The git part comes from `gitusers -p`, which takes ~35 ms, so it runs in the
# background for every prompt and zle picks up its output via `zle -F` as soon
# as it is ready; the previous RPROMPT stays visible until then
typeset -g __rprompt_fd=

# Assemble RPROMPT from the time, the conda env and the git part given as $1
__rprompt_set() {
    local -a parts=("${(%):-%*}")   # current time, without forking `date`
    [[ -n $CONDA_DEFAULT_ENV ]] && parts+=("%B${CONDA_DEFAULT_ENV:0:28}%b")
    parts+=("$1")
    # Assign the text itself (not a reference to it): gitusers emits
    # `$fg[...]` color codes that only work because PROMPT_SUBST expands them
    # again when RPROMPT is displayed
    RPROMPT="$parts"
}

# zle -F handler: called with the pipe's fd once gitusers' output is readable
__rprompt_done() {
    local fd=$1 git
    IFS= read -r -u $fd git   # gitusers prints no trailing newline; read stops at EOF
    zle -F $fd                # unregister the handler
    exec {fd}<&-              # close the pipe
    __rprompt_fd=

    __rprompt_set "$git"
    zle reset-prompt
}

__rprompt_start() {
    # Drop the computation still running for the previous prompt
    if [[ -n $__rprompt_fd ]]; then
        zle -F $__rprompt_fd
        exec {__rprompt_fd}<&-
    fi
    exec {__rprompt_fd}< <(gitusers -p 2>/dev/null)
    zle -F $__rprompt_fd __rprompt_done
}

if (( $+commands[gitusers] )); then
    # zle only redraws a right prompt that was already non-empty when it
    # started reading the line, so seed RPROMPT (time only) before the first
    # prompt; otherwise the git part would only show up from the second prompt
    __rprompt_set ''
    add-zsh-hook precmd __rprompt_start
fi
# }}}
# {{{ PROMPT: Show last exit-code
# Build the exit-code segment once per prompt in a precmd hook instead of
# forking a `$(...)` subshell from PROMPT; zsh passes every precmd hook the
# exit status of the last command
__prompt_status() {
    local st=$? label
    # Widgets re-run the precmd hooks via __execute_precmds without a new
    # command having run, and $? is then the widget's own status; keep the
    # segment of the last command in that case
    zle && return
    case $st in
        0)   __prompt_seg="%{$bg[blue]%}  %{$reset_color%}%{$fg[blue]%}"; return ;;
        127) __prompt_seg="%{$bg[yellow]%}  %{$reset_color%}%{$fg[yellow]%}"; return ;;  # unknown command
        255) label='-1' ;;    # display 255 as -1
        ?)   label="$st " ;;  # pad to two columns
        ??)  label=$st ;;
        *)   label='>>' ;;    # three digits do not fit
    esac
    __prompt_seg="%{$bg[red]%}%{$fg[black]%}${label}%{$reset_color%}%{$fg[red]%}"
}
add-zsh-hook precmd __prompt_status

setopt PROMPT_SUBST
PROMPT='${__prompt_seg} %n %{$fg[yellow]%}%~ %{$reset_color%}%% '
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
    # Prefer fd: it skips .git, hidden and gitignored files (e.g.
    # node_modules), which `find` would walk through below ~/workspace
    if (( $+commands[fd] )); then
        file=$(fd --type f | fzf) || { zle .reset-prompt; return 1; }
    else
        file=$(find * -type f | fzf) || { zle .reset-prompt; return 1; }
    fi
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
# {{{ fzf - pick dir recursively below current dir <Alt-d>
pick_dir_recursive() {
    local dir
    # Assign separately: `local x=$(...)` would mask fzf's exit status
    # Prefer fd: it skips .git, hidden and gitignored dirs (e.g.
    # node_modules), which `find` would walk through below ~/workspace
    if (( $+commands[fd] )); then
        dir=$(fd --type d | fzf) || { zle .reset-prompt; return 1; }
    else
        # -mindepth 1 drops `.` itself, sed strips the leading `./`
        dir=$(find . -mindepth 1 -type d | sed -E 's#^(\./)+##' | fzf) || { zle .reset-prompt; return 1; }
    fi
    LBUFFER+="$dir"

    __execute_precmds

    zle .reset-prompt
}
zle      -N  pick_dir_recursive{,}
bindkey '^[d' pick_dir_recursive
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
    podline=$(kubectl get pods --all-namespaces --no-headers -o=custom-columns=NAME:.metadata.name,Namespace:.metadata.namespace | fzf) || { zle .reset-prompt; return 1; }
    read -r pod namespace <<< "$podline"
    LBUFFER+="-n $namespace $pod"
    zle .reset-prompt
}
zle -N list_k8s_pods_via_fzf{,}
bindkey '^[p' list_k8s_pods_via_fzf
# }}}
# {{{ docker - list containers <Alt-c>
list_docker_containers_via_fzf() {
    local psout choice
    # Assign separately: `local x=$(...)` would mask the command's exit status
    psout=$(docker ps) || { zle .reset-prompt; return 1; }
    # Keep the `docker ps` header line pinned above the list
    choice=$(fzf --header-lines=1 <<< "$psout") || { zle .reset-prompt; return 1; }
    LBUFFER+=${choice%% *}   # first column: container ID
    zle .reset-prompt
}
zle -N list_docker_containers_via_fzf{,}
bindkey '^[c' list_docker_containers_via_fzf
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
# autocomplete q {{{
complete -C "q --list" q
# }}}


# settings shared between different shells
[ -f ~/.shellrc ] && source ~/.shellrc

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# fzf's key-bindings bind <Alt-c> to fzf-cd-widget, which would override our
# docker container picker bound further up, so (re)bind it after sourcing fzf
bindkey '^[c' list_docker_containers_via_fzf

# for local zshrc settings outside of dotfiles
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Deduplicate current PATH:
typeset -U path PATH

# @TODO clean local functions here bleeding into interactive shell context/scope

true # or else one-liner conditionals bleed their status into last_exit_code
