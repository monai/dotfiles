typeset -g NG_FREQUENT_DIRECTORIES_DB="${NGZSH_STATE_DIR}/frequent-directories.tsv"

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt PUSHD_TO_HOME

autoload -Uz add-zsh-hook chpwd_recent_dirs cdr
zstyle ':chpwd:*' recent-dirs-file "${NGZSH_STATE_DIR}/recent-dirs"
zstyle ':chpwd:*' recent-dirs-max 100
add-zsh-hook chpwd chpwd_recent_dirs

autoload -Uz ng-frequent-directories-add ng-frequent-directories-complete ng-frequent-directories-jump
alias j=ng-frequent-directories-jump

add-zsh-hook chpwd ng-frequent-directories-add
ng-frequent-directories-add
