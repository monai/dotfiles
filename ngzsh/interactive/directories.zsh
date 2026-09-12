typeset -g NG_FREQUENT_DIRECTORIES_DB="${NGZSH_STATE_DIR}/frequent-directories.tsv"
typeset -gaU ng_cd_pre_completion_functions

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt PUSHD_TO_HOME

autoload -Uz add-zsh-hook chpwd_recent_dirs cdr
zstyle ':chpwd:*' recent-dirs-file "${NGZSH_STATE_DIR}/recent-dirs"
zstyle ':chpwd:*' recent-dirs-max 100
add-zsh-hook chpwd chpwd_recent_dirs

autoload -Uz ng-frequent-directories-add ng-frequent-directories-complete

add-zsh-hook chpwd ng-frequent-directories-add
ng-frequent-directories-add

ng_cd_pre_completion_functions+=( ng-frequent-directories-complete )
