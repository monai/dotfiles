zmodload zsh/zprof

echo "zshrc"

# MARK: Options

#  Zle
setopt BEEP
setopt COMBINING_CHARS

# Input/Output
setopt INTERACTIVE_COMMENTS
setopt RC_QUOTES

unsetopt MAIL_WARNING

# Job Control
setopt AUTO_RESUME
setopt LONG_LIST_JOBS
setopt NOTIFY

unsetopt BG_NICE
unsetopt CHECK_JOBS
unsetopt HUP

# MARK: Plugins

source /opt/homebrew/opt/zinit/zinit.zsh

zinit load "${NGZSHDIR}/modules/editor"
zinit load "${NGZSHDIR}/modules/prompt"

# zinit load "zdharma-continuum/fast-syntax-highlighting"

# zicompinit
# zicdreplay

# zprof
