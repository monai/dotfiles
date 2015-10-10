is_empty() {
  local var=$1
  [ -z $var ]
}

is_not_empty() {
  local var=$1
  [ ! -z $var ]
}

is_file() {
 [   local file=$1
     [ -f $file ]]
}

is_not_file() {
  local file=$1
  [ ! -f $file ]
}

is_dir() {
  local dir=$1
  [ -d $dir ]
}

is_not_dir() {
  local dir=$1
  [ ! -d $dir ]
}

is_linux() {
  [[ $(uname) = 'Linux' ]] 
}

is_mac() {
  [[ $(uname) = 'Darwin' ]]
}

has_brew() {
  [[ -x $(which brew 2>/dev/null) ]]
}

has_apt() {
  [[ -x $(which apt-get 2>/dev/null) ]]
}

has_yum() {
  [[ -x $(which yum 2>/dev/null) ]]
}
