0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

if [[ ${zsh_loaded_plugins[-1]} != */frequent-directories && -z ${fpath[(r)${0:h}/functions]} ]] {
  fpath+=( "${0:h}/functions" )
}

if [[ $PMSPEC != *f* ]] {
  fpath+=( "${0:h}/functions" )
}

typeset -gA Plugins
Plugins[FREQUENT_DIRECTORIES_DIR]="${0:h}"

# ----

typeset -g NG_FREQUENT_DIRECTORIES_DB="${NGZSH_STATE_DIR}/frequent-directories.tsv"
typeset -gaU ng_cd_pre_completion_functions

autoload -Uz add-zsh-hook ng-frequent-directories-add ng-frequent-directories-complete

add-zsh-hook chpwd ng-frequent-directories-add
ng-frequent-directories-add

ng_cd_pre_completion_functions+=( ng-frequent-directories-complete )
