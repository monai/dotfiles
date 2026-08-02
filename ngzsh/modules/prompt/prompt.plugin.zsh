0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

if [[ ${zsh_loaded_plugins[-1]} != */prompt && -z ${fpath[(r)${0:h}/functions]} ]] {
  fpath+=( "${0:h}/functions" )
}

if [[ $PMSPEC != *f* ]] {
  fpath+=( "${0:h}/functions" )
}

typeset -gA Plugins
Plugins[PROMPT_DIR]="${0:h}"

# ----

autoload promptinit && promptinit
prompt ng
