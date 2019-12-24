atom() {
  local args="$@"
  if (( $+commands[atom-beta] )); then
    $commands[atom-beta] ${=args}
  else
    $commands[atom] ${=args}
  fi
}

stub_cmd_aws() {
  unset -f aws
  load_zsh_completion "aws_zsh_completer.sh"
}

aws() {
  local args="$@"
  stub_cmd_aws
  aws ${=args}
}

stub_cmd_dnvm() {
  unset -f dnvm
  if [[ -x $(which "${init}" 2>/dev/null) ]]; then
    source "${init}"
    export DOTNET_CLI_TELEMETRY_OPTOUT=1
  fi
}

dnvm() {
  local args=${1+"$@"}
  local init=dnvm.sh
  stub_cmd_dnvm

  if is-empty "${args}"; then
    dnvm
  else
    dnvm ${=args}
  fi
}

stub_cmd_kubectl() {
  unset -f kubectl
  load_zsh_completion "_kubectl"
}

kubectl() {
  local args="$@"
  stub_cmd_kubectl
  kubectl ${=args}
}

stub_cmd_nvm() {
  unset -f nvm
  zgen prezto node
  load_bash_completion "nvm"
}

nvm() {
  local args="$@"
  stub_cmd_nvm
  nvm ${=args}
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

stub_cmd_stack() {
  unset -f stack
  autoload -U +X bashcompinit && bashcompinit
  eval "$(stack --bash-completion-script stack)"
}

stack() {
  local args="$@"
  stub_cmd_stack
  stack ${=args}
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
