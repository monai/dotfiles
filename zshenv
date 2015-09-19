typeset -U path

function path_append_path_helper() {
    if [ -x /usr/libexec/path_helper ]; then
        PATH=''
        MANPATH=''
        eval $(/usr/libexec/path_helper -s)
        path=(${(@s/:/)PATH})
        manpath=(${(@s/:/)MANPATH})
    fi
}

function path_append_if_exist() {
    local dir=$1
    if [ -d $dir ]; then
        path=($dir $path)
    fi
}

function manpath_append_if_exist() {
    local dir=$1
    if [ -d $dir ]; then
        manpath=($dir $manpath)
    fi
}

path_append_path_helper

path_append_if_exist /usr/local/bin
path_append_if_exist /opt/puppetlabs/bin
path_append_if_exist $HOME/usr/bin

path=(
    ./node_modules/.bin
    ../node_modules/.bin
    ../../node_modules/.bin
    $path
)

manpath_append_if_exist /opt/puppetlabs/puppet/share/man

if [ -z $XDG_CONFIG_HOME ] && [ -d $HOME/.config ]; then
    export XDG_CONFIG_HOME=$HOME/.config
fi

if [ -d $HOME/projects ]; then
    export PROJECT_HOME=$HOME/projects
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
fi

if [ -d $HOME/.nvm ]; then
    export NVM_DIR=$HOME/.nvm
fi
