# Extract archive
function ex() {
    readonly name=$(basename $0)
    local file=$1
    
    if $(is_empty $file); then
        echo "usage: $name archive" >&2
        return 1
    elif $(is_file $file); then
        case $file in
            *.tar.bz2) tar xvjf $file;;
            *.tar.gz) tar xvzf $file;;
            *.tar.xz) tar xvJf $file;;
            *.tar.lzma) tar --lzma xvf $file;;
            *.bz2) bunzip $file;;
            *.rar) unrar x $file;;
            *.gz) gunzip $file;;
            *.tar) tar xvf $file;;
            *.tbz2) tar xvjf $file;;
            *.tgz) tar xvzf $file;;
            *.zip) unzip $file;;
            *.Z) uncompress $file;;
            *.7z) 7z x $file;;
            *.dmg) hdiutul mount $file;; # mount OS X disk images
            *) echo "$name: '$file' is not supported archive file";;
        esac
    else
        echo "$name: '$file' is not file"
    fi
}

# Process pattern search
function ps-grep() {
    readonly name=$(basename $0)
    local pattern=$1
    
    emulate -L zsh
    unsetopt KSH_ARRAYS
    if $(is_empty $pattern); then
        echo "usage: $name pattern" >&2
        return 1
    else
        ps xauwww | grep -i --color=auto "[${pattern[1]}]${pattern[2,-1]}"
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
