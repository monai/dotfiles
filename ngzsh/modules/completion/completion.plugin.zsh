0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

if [[ ${zsh_loaded_plugins[-1]} != */completion && -z ${fpath[(r)${0:h}/functions]} ]] {
  fpath+=( "${0:h}/functions" )
}

if [[ $PMSPEC != *f* ]] {
  fpath+=( "${0:h}/functions" )
}

typeset -gA Plugins
Plugins[COMPLETION_DIR]="${0:h}"

# ----

autoload -Uz compinit
compinit -C -d "${NGZSH_CACHE_DIR}/.zcompdump"

typeset -gaU ng_cd_pre_completion_functions
ng_cd_pre_completion_functions=()

autoload -Uz _ng_cd_pre_complete
compdef -p _ng_cd_pre_complete '(cd|chdir|pushd)'
