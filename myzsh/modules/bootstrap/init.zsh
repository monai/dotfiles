bootstrap_load_module() {
  local module=$1
  zgen prezto "${module}"
}

nvm() {
  local args="$@"
  unset -f nvm
  bootstrap_load_module node
  nvm ${=args}
}

pyenv() {
  local args="$@"
  unset -f pyenv
  bootstrap_load_module python

  if (( $+commands[pyenv-virtualenv-init] )); then
    eval "$(pyenv virtualenv-init -)"
  fi

  if (( $+commands[pyenv] )); then
    export PYTHONHOME=$(pyenv prefix)
  fi

  # TODO: move to python module
  export PYENV_VIRTUALENV_DISABLE_PROMPT=1

  pyenv ${=args}
}

rbenv() {
  local args="$@"
  unset -f rbenv
  bootstrap_load_module ruby
  rbenv ${=args}
}

dnvm() {
  local args=${1+"$@"}
  local init=dnvm.sh

  unset -f dnvm

  if [[ -x $(which "${init}" 2>/dev/null) ]]; then
    source "${init}"
    if is_empty "${args}"; then
      dnvm
    else
      dnvm ${=args}
    fi
  fi
}

stack() {
  echo "stack"
  local args="$@"
  unset -f stack
  autoload -U +X bashcompinit && bashcompinit
  eval "$(stack --bash-completion-script stack)"
  stack ${=args}
}
