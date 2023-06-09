local condahome
for prefix in ${condahomepath[@]}; do
  if [[ -d $prefix ]]; then
    condahome=$prefix
    break
  fi
done

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('${condahome}/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
  eval "$__conda_setup"
else
  if [ -f "${condahome}/etc/profile.d/conda.sh" ]; then
    . "${condahome}/etc/profile.d/conda.sh"
  else
    export PATH="${condahome}/bin:$PATH"
  fi
fi
unset __conda_setup
# <<< conda initialize <<<
