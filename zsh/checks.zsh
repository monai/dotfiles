function is_empty() {
    local var=$1
    [ -z $var ]
}

function is_not_empty() {
    local var=$1
    [ ! -z $var ]
}

function is_file() {
    local file=$1
    [ -f $file ]
}

function is_not_file() {
    local file=$1
    [ ! -f $file ]
}

function is_dir() {
    local dir=$1
    [ -d $dir ]
}

function is_not_dir() {
    local dir=$1
    [ ! -d $dir ]
}

function is_linux() {
   [[ $(uname) = 'Linux' ]] 
}

function is_mac() {
    [[ $(uname) = 'Darwin' ]]
}

function has_brew() {
    [[ -x $(which brew 2>/dev/null) ]]
}

function has_apt() {
    [[ -x $(which apt-get 2>/dev/null) ]]
}

function has_yum() {
    [[ -x $(which yum 2>/dev/null) ]]
}
