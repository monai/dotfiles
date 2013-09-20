HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

bindkey -v
export KEYTIMEOUT=1

zstyle :compinstall filename '~/.zshrc'

autoload -Uz compinit
compinit

autoload -U colors
colors

setopt PROMPT_SUBST

# Autoload functions
fpath=(~/.zsh/functions $fpath)
autoload -U ~/.zsh/functions/*(:t)

# Enable auto-execution of functions.
typeset -ga preexec_functions
typeset -ga precmd_functions
typeset -ga chpwd_functions

# Append git functions needed for prompt.
preexec_functions+='preexec_update_git_vars'
precmd_functions+='precmd_update_git_vars'
chpwd_functions+='chpwd_update_git_vars'

# Git flow
source ~/.zsh/functions/git-flow-completion.zsh

# ENV
PROMPT='%~/'
PROMPT+='$(prompt_git_info)'
PROMPT+='%{$reset_color%} '

precmd() {
    #print "${fg[white]}---"
}

export EDITOR='vim'
export TERM='xterm-256color'

# Aliases
alias ls='ls -hX --color=auto'
alias l='ls'
alias ll='ls -lF'
alias la='ll -A'

# Virtualenv
source /etc/bash_completion.d/virtualenvwrapper

