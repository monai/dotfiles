# Directory movement
alias ..='cd ..'
alias ...='cd ../..'

# Directory information
if [[ $IS_LINUX -eq 1 ]] then
    alias ls='ls -hXF --color=auto'
    alias l='ls -hXF --color=auto'
    alias ll='ls -lhXF'
    alias la='ll -AlhXF'
    alias lh='ls -dlhXF .*'
fi
if [[ $IS_MAC -eq 1 ]] then
    alias ls='ls -hGF'
    alias l='ls -hGF'
    alias ll='ls -lhGF'
    alias la='ll -AlhGF'
    alias lh='ls -dlhGF .*'
fi

# Mac only
if [[ $IS_MAC -eq 1 ]] then
    alias ql='qlmanage -p 2>/dev/null' # OS X Quick Look
    alias oo='open .' # open current directory in OS X Finder
fi

# Git
alias ga='git add'
alias gp='git push'
alias gl='git log'
alias gpl="git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
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
alias gta='git tag -a -m'
alias gf='git reflog'
alias gv='git log --pretty=format:'%s' | cut -d " " -f 1 | sort | uniq -c | sort -nr'

# leverage aliases from ~/.gitconfig
alias gh='git hist'
alias gt='git today'

# curiosities 
# gsh shows the number of commits for the current repos for all developers
alias gsh="git shortlog | grep -E '^[ ]+\w+' | wc -l"

# gu shows a list of all developers and the number of commits they've made
alias gu="git shortlog | grep -E '^[^ ]'"
