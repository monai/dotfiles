autoload -Uz vcs_info
autoload -Uz chpwd_recent_dirs cdr

function precmd() {
    # Put the string "hostname::/full/directory/path" in the title bar
    echo -ne "\e]2;$PWD\a"
    
    # Put the parentdir/currentdir in the tab
    echo -ne "\e]1;$PWD:h:t/$PWD:t\a"
    
    # Get the current git branch into the prompt
    vcs_info
}

function preexec() {
    printf "\e]1; $PWD:t:$(history $HISTCMD | cut -b7- ) \a"
}

function chpwd() {
    chpwd_recent_dirs
}
