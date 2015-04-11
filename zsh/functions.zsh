# Extract archive
function ex() {
    readonly name=$(basename $0)
    readonly file=$1
    
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
    readonly pattern=$1
    
    if $(is_empty $pattern); then
        echo "usage: $name pattern" >&2
        return 1
    else
        ps aux \
            | grep "$pattern"
    fi
}

# Display a neatly formatted path
function path() {
    echo $PATH \
        | tr ":" "\n" \
        | awk "{ sub(\"/usr\",   \"$FG[green]/usr$FX[reset]\"); \
                 sub(\"/bin\",   \"$FG[blue]/bin$FX[reset]\"); \
                 sub(\"/opt\",   \"$FG[cyan]/opt$FX[reset]\"); \
                 sub(\"/sbin\",  \"$FG[magenta]/sbin$FX[reset]\"); \
                 sub(\"/local\", \"$FG[yellow]/local$FX[reset]\"); \
                 print }"
}

# Tail syslog
function syslog-tail() {
    set -A patterns $@
    readonly query=${(j:|:)patterns}
    
    if $(is_not_empty $patterns); then
        tail -f /var/log/system.log | grep -E "$query"
    else
        tail -f /var/log/system.log
    fi
}

# Listening ports
function listen-ls() {
    netstat -lan | grep --color=never "LISTEN "
}

# Mount ramdisk
# function ramdisk() {
#     readonly name=$(basename $0)
#     readonly size=$1
#     typeset -A multipliers
#     local multiplier
#
#     if $(is_empty size); then
#         echo "usage: $name size" >&2
#         return 1
#     fi
#
#     multipliers=(K 1e3 M 1e6 G 1e9 T 1e12 P 1e15)
# }
