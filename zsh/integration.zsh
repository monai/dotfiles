# Python environments
if $(which pyenv >/dev/null 2>&1); then
    eval "$(pyenv init -)";
    
    # Source virtualenvwrapper
    # pyenv virtualenvwrapper
else
    vw=/usr/share/virtualenvwrapper/virtualenvwrapper.sh
    if [ -f $vw ]; then
        source $vw
    fi
fi

if $(which rbenv >/dev/null 2>&1); then
    eval "$(rbenv init -)";
fi

if [ -f $NVM_DIR/nvm.sh ]; then
    source $NVM_DIR/nvm.sh
fi

Z_DATA=$HOME/.zsh/cache/z

if $(is_not_file $Z_DATA); then
    touch $Z_DATA
fi
