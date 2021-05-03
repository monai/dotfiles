atom() {
  local args="$@"
  if (( $+commands[atom-beta] )); then
    $commands[atom-beta] ${=args}
  else
    $commands[atom] ${=args}
  fi
}

stub_cmd_pyenv() {
  if (( ${+functions[pyenv]} )); then
    unset -f pyenv
  fi
  pmodload 'python'

  if (( $+commands[pyenv-virtualenv-init] )); then
    eval "$(pyenv virtualenv-init -)"
  fi

  if (( $+commands[pyenv] )); then
    export PYTHONHOME=$(pyenv prefix)
  fi

  export PYENV_VIRTUALENV_DISABLE_PROMPT=12
}

pyenv() {
  local args="$@"
  stub_cmd_pyenv
  pyenv ${=args}
}

stub_cmd_rbenv() {
  if (( ${+functions[rbenv]} )); then
    unset -f rbenv
  fi
  pmodload 'ruby'
}

rbenv() {
  local args="${@:-version}"
  stub_cmd_rbenv
  rbenv ${=args}
}

stub_cmd_rustup() {
  if (( ${+functions[rustup]} )); then
    unset -f rustup
  fi
  source "${HOME}/.cargo/env"
}

rustup() {
  local args="$@"
  stub_cmd_rustup
  rustup ${=args}
}

stub_cmd_perlbrew() {
  if (( ${+functions[perlbrew]} )); then
    unset -f perlbrew
  fi
  source "$HOME/perl5/perlbrew/etc/bashrc"
}

perlbrew() {
  local args="$@"
  stub_cmd_perlbrew
  perlbrew ${=args}
}

stub_cmd_nvm() {
  if (( ${+functions[nvm]} )); then
    unset -f nvm
  fi
  pmodload 'node'
}

nvm() {
  local args="$@"
  stub_cmd_nvm
  nvm ${=args}
}
