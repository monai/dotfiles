zmodload zsh/zprof

echo "zshrc"

# MARK: Builtins

# builtin
# !
# %
# .
# :
# @
# [
# {
# }
# alias
# alloc
# bg
# bind
# bindkey
# break
# breaksw
# builtins
# case
# cd
# chdir
# command
# complete
# continue
# default
# dirs
# do
# done
# echo
# echotc
# elif
# else
# end
# endif
# endsw
# esac
# eval
# exec
# exit
# export
# false
# fc
# fg
# filetest
# fi
# for
# foreach
# getopts
# glob
# goto
# hash
# hashstat
# history
# hup
# if
# jobid
# jobs
# kill
# limit
# local
# log
# login
# logout
# ls-F
# nice
# nohup
# notify
# onintr
# popd
# printenv
# printf
# pushd
# pwd
# read
# readonly
# rehash
# repeat
# return
# sched
# set
# setenv
# settc
# setty
# setvar
# shift
# source
# stop
# suspend
# switch
# telltc
# test
# then
# time
# times
# trap
# true
# type
# ulimit
# umask
# unalias
# uncomplete
# unhash
# unlimit
# unset
# unsetenv
# until
# wait
# where
# which
# while

# MARK: Parameters
# https://zsh.sourceforge.io/Doc/Release/Parameters.html#Parameters-Used-By-The-Shell

HISTSIZE=100000
SAVEHIST=$HISTSIZE
HISTFILE="${NGZSH_STATE_DIR}/history"

# MARK: Options
# https://zsh.sourceforge.io/Doc/Release/Options.html

# Zle
setopt BEEP
setopt COMBINING_CHARS

# Input/Output
setopt INTERACTIVE_COMMENTS
setopt MULTIOS
setopt RC_QUOTES

unsetopt CLOBBER

# Globbing
setopt EXTENDED_GLOB

# Job Control
setopt AUTO_RESUME
setopt LONG_LIST_JOBS

unsetopt BG_NICE
unsetopt CHECK_JOBS
unsetopt HUP

# History
setopt EXTENDED_HISTORY
setopt HIST_BEEP
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt SHARE_HISTORY

# Directories
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt PUSHD_TO_HOME

# Completion
setopt ALWAYS_TO_END
setopt AUTO_LIST
setopt AUTO_MENU
setopt AUTO_PARAM_SLASH
setopt COMPLETE_IN_WORD
setopt PATH_DIRS

unsetopt FLOW_CONTROL
unsetopt MENU_COMPLETE

# MARK: Plugins

ngzsh-load() {
  local dir="$1"
  local plugin="${dir}/${dir:t}.plugin.zsh"

  [[ -r "$plugin" ]] || return 1

  fpath+=( "$dir/functions" )

  local ZERO="$plugin"
  local PMSPEC=f
  typeset -ga zsh_loaded_plugins
  zsh_loaded_plugins+=( "$dir" )

  source "$plugin"
}

ngzsh-load "${NGZSHDIR}/modules/history"
ngzsh-load "${NGZSHDIR}/modules/editor"
ngzsh-load "${NGZSHDIR}/modules/prompt"

# ----

mkdir -p -- "$NGZSH_CACHE_DIR" "$NGZSH_STATE_DIR"

autoload -Uz add-zsh-hook chpwd_recent_dirs cdr
zstyle ':chpwd:*' recent-dirs-file "${NGZSH_STATE_DIR}/recent-dirs"
zstyle ':chpwd:*' recent-dirs-max 100
add-zsh-hook chpwd chpwd_recent_dirs

# ----

autoload -Uz compinit
compinit -C -d "${NGZSH_CACHE_DIR}/.zcompdump"

# ----

zstyle ':completion:*' completer _complete _approximate
zstyle ':completion:*' menu yes select

# Cache slow command lookups
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "${NGZSH_CACHE_DIR}/compcache"

# Group results by type
zstyle ':completion:*' group-name ''

# Show descriptions for groups
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

# Better formatting for warnings/messages
zstyle ':completion:*:warnings' format '%F{red}no matches found%f'
zstyle ':completion:*:messages' format '%F{cyan}%d%f'

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ----

# zprof
