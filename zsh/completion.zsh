autoload -U compinit && compinit
zmodload -i zsh/complist

# Take the first part of the path to be exact, and to avoid partial globs
zstyle ':completion:*' accept-exact '*(N)'

# Enable completion caching, use rehash to clear
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Fallback to built in ls colors
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Make the list prompt friendly
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'

# Make the selection prompt friendly when there are a lot of choices
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

# Add simple colors to kill
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

# List of completers to use
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate
zstyle ':completion:*' menu select=1 _complete _ignored _approximate

# Max errors for _approximate completer
zstyle ':completion:*' max-errors 1

# Insert all expansions for expand completer
# zstyle ':completion:*:expand:*' tag-order all-expansions

# Match uppercase from lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Formatting and messages
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''

# Ignore completion functions (until the _ignored completer)
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:scp:*' tag-order files users 'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
zstyle ':completion:*:scp:*' group-order files all-files users hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' tag-order users 'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
zstyle ':completion:*:ssh:*' group-order hosts-domain hosts-host users hosts-ipaddr
zstyle '*' single-ignored show

# man zshcontrib
zstyle ':vcs_info:*' actionformats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:*' enable git hg svn

function _load_bash_completions() {
    local base=$1; shift
    set -A files $@
    local file
    
    for file in $@; do
        file="$base/${file}"
        if $(is_file $file); then
            source $file
        fi
    done
}

function _setup_completion() {
    local brew_path=$(brew --prefix)
    local nvm_path=$HOME/.nvm/bash_completion
    
    if $(has_brew); then
        fpath=($brew_path/share/zsh/site-functions $fpath)
    
        _load_bash_completions ${brew_path}/etc/bash_completion.d \
            tig-completion.bash \
            youtube-dl.bash-completion \
            npm
        
        _load_bash_completions $HOME/.nvm \
            bash_completion
        
        _load_bash_completions $HOME/.nvm
    
        compinit
    fi
}

_setup_completion
