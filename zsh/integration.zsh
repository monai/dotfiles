# Python environments
if which pyenv > /dev/null; then
    eval "$(pyenv init -)";
    
    # Source virtualenvwrapper
    # pyenv virtualenvwrapper
else
    vw=/usr/share/virtualenvwrapper/virtualenvwrapper.sh
    if [ -f $vw ]; then
        source $vw
    fi
fi

if which rbenv > /dev/null; then
    eval "$(rbenv init -)";
fi

if [ -f $HOME/.nvm/nvm.sh ]; then
    source $HOME/.nvm/nvm.sh
fi

