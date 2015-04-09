# Directory movement
alias ..='cd ..'
alias ...='cd ../..'

# Directory information
if $(is_linux); then
    alias ls='ls -hXF --color=auto'
    alias l='ls'
    alias ll='ls -l'
    alias la='ll -A'
    alias lh='ll -d .*'
fi
if $(is_mac); then
    alias ls='ls -hF'
    alias l='ls'
    alias ll='ls -l'
    alias la='ll -A'
    alias lh='ll -d .*'
fi

# Mac only
if $(is_mac); then
    alias ql='qlmanage -p 2>/dev/null' # OS X Quick Look
    alias oo='open .' # open current directory in OS X Finder
fi

# Git
if [ -f '/usr/local/bin/git' ]; then
    # Use homebrew git
    alias git='/usr/local/bin/git'
fi

alias ga='git add'
alias gp='git push'
alias gl='git log'
alias gpl="git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gplg='gpl --graph'
alias gs='git status'
alias gd='git diff'
alias gm='git commit -m'
alias gma='git commit -am'
alias gb='git branch'
alias gc='git checkout'
alias gcb='git checkout -b'
alias gra='git remote add'
alias grr='git remote rm'
alias gpu='git pull'
alias gcl='git clone'
alias gta='git tag -am'
alias gf='git reflog'
alias gv='git log --pretty=format:'%s' | cut -d " " -f 1 | sort | uniq -c | sort -nr'
