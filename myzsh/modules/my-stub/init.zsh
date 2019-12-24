atom() {
  local args="$@"
  if (( $+commands[atom-beta] )); then
    $commands[atom-beta] ${=args}
  else
    $commands[atom] ${=args}
  fi
}

stub_cmd_pyenv() {
  unset -f pyenv
  zgen prezto python

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
  unset -f rbenv
  zgen prezto ruby
}

rbenv() {
  local args="${@:-version}"
  stub_cmd_rbenv
  rbenv ${=args}
}

stub_cmd_rustup() {
  unset -f rustup
  source "${HOME}/.cargo/env"
}

rustup() {
  local args="$@"
  stub_cmd_rustup
  rustup ${=args}
}

stub_cmd_perlbrew() {
  unset -f perlbrew
  source "$HOME/perl5/perlbrew/etc/bashrc"
}

perlbrew() {
  local args="$@"
  stub_cmd_perlbrew
  perlbrew ${=args}
}
