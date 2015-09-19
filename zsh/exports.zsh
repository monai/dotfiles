export CLICOLOR
export LSCOLORS
export LS_COLORS

export GREP_OPTIONS
export GREP_COLOR

# This resolves issues install the mysql, postgres, and other gems with native non universal binary extensions
export ARCHFLAGS='-arch x86_64'

export TERM=xterm-256color
export LESS='--ignore-case --raw-control-chars'
export PAGER='less'
export EDITOR='vim'

export KEYTIMEOUT=1

export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

export VIRTUAL_ENV_DISABLE_PROMPT=true

export CDPATH=".:~:$PROJECT_HOME:$GOPATH"

if $(is_mac); then
    export HOMEBREW_CASK_OPTS="--appdir=/Applications"
fi

export _Z_DATA=$Z_DATA
