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
            *.rar) unrar x $1;;
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
        awk "{ sub(\"/usr\",   \"$FG[green]/usr$FX[reset]\"); \
               sub(\"/bin\",   \"$FG[blue]/bin$FX[reset]\"); \
               sub(\"/opt\",   \"$FG[cyan]/opt$FX[reset]\"); \
               sub(\"/sbin\",  \"$FG[magenta]/sbin$FX[reset]\"); \
               sub(\"/local\", \"$FG[yellow]/local$FX[reset]\"); \
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
