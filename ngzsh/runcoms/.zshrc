# echo "zshrc"

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

# MARK: Options
# https://zsh.sourceforge.io/Doc/Release/Options.html

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

unsetopt FLOW_CONTROL

# MARK: Directories

mkdir -p -- "$NGZSH_CACHE_DIR" "$NGZSH_STATE_DIR"

# MARK: Functions

fpath=( "${NGZSHDIR}/functions" $fpath )

# MARK: Interactive Setup

source "${NGZSHDIR}/interactive/history.zsh"
source "${NGZSHDIR}/interactive/completion.zsh"
source "${NGZSHDIR}/interactive/directories.zsh"
source "${NGZSHDIR}/interactive/editor.zsh"
source "${NGZSHDIR}/interactive/signals.zsh"
source "${NGZSHDIR}/interactive/prompt.zsh"
