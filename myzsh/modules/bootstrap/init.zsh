bootstrap_load_module() {
  local module=$1
  zgen prezto "${module}"
}

nvm() {
  unset -f nvm
  local args="$@"
  bootstrap_load_module node
  nvm "${args}"
}

pyenv() {
  unset -f pyenv
  local args="$@"
  bootstrap_load_module python
  
  if (( $+commands[pyenv-virtualenv-init] )); then
    eval "$(pyenv virtualenv-init -)"
  fi

  if (( $+commands[pyenv] )); then
    export PYTHONHOME=$(pyenv prefix)
  fi

  # TODO: move to python module
  export PYENV_VIRTUALENV_DISABLE_PROMPT=1
  
  pyenv "${args}"
}

rbenv() {
  unset -f rbenv
  local args="$@"
  bootstrap_load_module ruby
  rbenv "${args}"
}
