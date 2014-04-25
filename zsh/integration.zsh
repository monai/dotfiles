# python
if which pyenv > /dev/null; then
    eval "$(pyenv init -)";
else
    vw=/usr/share/virtualenvwrapper/virtualenvwrapper.sh
    if [ -f $vw ]; then
        source $vw
    fi
fi


