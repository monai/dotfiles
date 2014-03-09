# Mac OS X uses path_helper and /etc/paths.d to preload PATH, clear it out first
if [ -x /usr/libexec/path_helper ]; then
    PATH=''
    eval `/usr/libexec/path_helper -s`
fi

if [ -z "$XDG_CONFIG_HOME" ]; then
    if [ -d "$HOME/.config" ]; then
        export XDG_CONFIG_HOME="${HOME}/.config"
    fi
fi
