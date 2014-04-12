# Extract archive
function ex() {
    if [[ -z $1 ]] then
        echo "usage: $0 archive" >&2
        return 1
    elif [[ -f $1 ]] then
        case $1 in
            *.tar.bz2) tar xvjf $1;;
            *.tar.gz) tar xvzf $1;;
            *.tar.xz) tar xvJf $1;;
            *.tar.lzma) tar --lzma xvf $1;;
            *.bz2) bunzip $1;;
            *.rar) unrar $1;;
            *.gz) gunzip $1;;
            *.tar) tar xvf $1;;
            *.tbz2) tar xvjf $1;;
            *.tgz) tar xvzf $1;;
            *.zip) unzip $1;;
            *.Z) uncompress $1;;
            *.7z) 7z x $1;;
            *.dmg) hdiutul mount $1;; # mount OS X disk images
            *) echo "$0: '$1' is not supported archive file";;
        esac
    else
        echo "$0: '$1' is not file"
    fi
}

# Process pattern search
function ps-grep() {
    emulate -L zsh
    unsetopt KSH_ARRAYS
    if [[ -z $1 ]]; then
        echo "usage: $0 pattern" >&2
        return 1
    else
        ps xauwww | grep -i --color=auto "[${1[1]}]${1[2,-1]}"
    fi
}

# Display a neatly formatted path
function path() {
    echo $PATH | tr ":" "\n" | \
        awk "{ sub(\"/usr\",   \"$fg_no_bold[green]/usr$reset_color\"); \
               sub(\"/bin\",   \"$fg_no_bold[blue]/bin$reset_color\"); \
               sub(\"/opt\",   \"$fg_no_bold[cyan]/opt$reset_color\"); \
               sub(\"/sbin\",  \"$fg_no_bold[magenta]/sbin$reset_color\"); \
               sub(\"/local\", \"$fg_no_bold[yellow]/local$reset_color\"); \
               print }"
}

# Tail syslog
function syslog-tail() {
    if [[ $# -gt 0 ]]; then
        query=$(echo "$*" | tr -s ' ' '|')
        tail -f /var/log/system.log | grep -i --color=auto -E "$query"
    else
        tail -f /var/log/system.log
    fi
}

# Listening ports
function listen-ls() {
    netstat -lan | grep --color=never "LISTEN "
}
