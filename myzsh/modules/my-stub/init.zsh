stub_cmd_pyenv() {
  if (( ${+functions[pyenv]} )); then
    unset -f pyenv
  fi
  pmodload 'python'

  if (( $+commands[pyenv-init] )); then
    eval "$(pyenv init -)"
  fi

  if (( $+commands[pyenv-prefix] )); then
    export PYTHONHOME=$(pyenv prefix)
  fi

  export VIRTUAL_ENV_DISABLE_PROMPT=1
  export PYENV_VIRTUALENV_DISABLE_PROMPT=12
}

pyenv() {
  local args="$@"
  stub_cmd_pyenv
  pyenv ${=args}
}

stub_cmd_conda() {
  if (( ${+functions[conda]} )); then
    unset -f conda
  fi

  pmodload 'my-conda'
  pmodload 'python'

  export CONDA_ENV_PROMPT=""
}

conda() {
  local args="$@"
  stub_cmd_conda
  conda ${=args}
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

stub_cmd_nodenv() {
  if (( ${+functions[nvm]} )); then
    unset -f nodenv
  fi
  pmodload 'node'
}

nodenv() {
  local args="$@"
  stub_cmd_nodenv
  nodenv ${=args}
}
