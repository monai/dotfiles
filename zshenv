if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'

if [[ -z "$LANG" ]]; then
  eval "$(locale)"
fi

export LESS='-F -g -i -M -R -S -w -X -z-4'



typeset -gU cdpath fpath mailpath manpath path
typeset -gUT INFOPATH infopath

if [ -x /usr/libexec/path_helper ]; then
    PATH=''
    MANPATH=''
    eval $(/usr/libexec/path_helper -s)
    path=(${(@s/:/)PATH})
    manpath=(${(@s/:/)MANPATH})
fi

cdpath=(
  .
  ~
  $cdpath
)

infopath=(
  $HOME/usr/share/info
  /usr/local/share/info
  /usr/share/info
  $infopath
)

manpath=(
  $HOME/usr/share/man
  /opt/puppetlabs/puppet/share/man
  $manpath
)

path=(
  ./node_modules/.bin
  ../node_modules/.bin
  ../../node_modules/.bin
  $HOME/usr/{bin,sbin}
  /usr/local/{bin,sbin}
  /opt/puppetlabs/bin
  $path
)


if [ -z $XDG_CONFIG_HOME ] && [ -d $HOME/.config ]; then
  export XDG_CONFIG_HOME=$HOME/.config
fi

if [ -d $HOME/projects ]; then
  export PROJECT_HOME=$HOME/projects
  cdpath=($PROJECT_HOME $cdpath)
fi

if [ -d $HOME/.virtualenvs ]; then
  export WORKON_HOME=$HOME/.virtualenvs
  export PIP_VIRTUALENV_BASE=$WORKON_HOME
  export PIP_RESPECT_VIRTUALENV=true
fi

if [ -d $PROJECT_HOME/go ]; then
  export GOPATH=$PROJECT_HOME/go
  export GOBIN=$GOPATH/bin
  path=($GOBIN $path)
  cdpath=($GOPATH $cdpath)
fi

if [ -d $HOME/.nvm ]; then
  export NVM_DIR=$HOME/.nvm
fi
