# Mac OS X uses path_helper and /etc/paths.d to preload PATH, clear it out first
if [ -x /usr/libexec/path_helper ]; then
    PATH=''
    eval $(/usr/libexec/path_helper -s)
fi

if [ -d $HOME/usr/bin ]; then
    path=($HOME/usr/bin $path)
fi

if [ -z $XDG_CONFIG_HOME ] && [ -d $HOME/.config ]; then
    export XDG_CONFIG_HOME=${HOME}/.config
fi

if [ -d $HOME/projects ]; then
    export PROJECT_HOME=$HOME/projects
fi

if [ -d $HOME/.virtualenvs ]; then
    export WORKON_HOME=$HOME/.virtualenvs
    export PIP_VIRTUALENV_BASE=$WORKON_HOME
    export PIP_RESPECT_VIRTUALENV=true
fi
