CONDA_PREFIX="${BREW_PREFIX}/anaconda3"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('${CONDA_PREFIX}/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
  eval "$__conda_setup"
else
  if [ -f "${CONDA_PREFIX}/etc/profile.d/conda.sh" ]; then
    . "${CONDA_PREFIX}/etc/profile.d/conda.sh"
  else
    export PATH="${CONDA_PREFIX}/bin:$PATH"
  fi
fi
unset __conda_setup
# <<< conda initialize <<<
