# Enable color in grep
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='3;33'

# This resolves issues install the mysql, postgres, and other gems with native non universal binary extensions
export ARCHFLAGS='-arch x86_64'

export LESS='--ignore-case --raw-control-chars'
export PAGER='less'
export EDITOR='vim'

export KEYTIMEOUT=1

export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

export CDPATH='.:~:~/projects'
