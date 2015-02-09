# Python environments
if which pyenv 2>&1 >/dev/null; then
    eval "$(pyenv init -)";
    
    # Source virtualenvwrapper
    # pyenv virtualenvwrapper
else
    vw=/usr/share/virtualenvwrapper/virtualenvwrapper.sh
    if [ -f $vw ]; then
        source $vw
    fi
fi

if which rbenv 2>&1 >/dev/null; then
    eval "$(rbenv init -)";
fi

if [ -f $NVM_DIR/nvm.sh ]; then
    source $NVM_DIR/nvm.sh
fi
