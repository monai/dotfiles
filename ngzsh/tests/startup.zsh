#!/usr/bin/env zsh

emulate -L zsh
setopt err_return pipe_fail

typeset -r repo_ngzsh_dir="${0:A:h:h}"
typeset -r functions_dir="${repo_ngzsh_dir}/functions"

assert_equals() {
  local actual="$1"
  local expected="$2"

  if [[ "$actual" != "$expected" ]]; then
    print -ru2 -- "expected: $expected"
    print -ru2 -- "actual:   $actual"
    return 1
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"

  if [[ "$haystack" != *"$needle"* ]]; then
    print -ru2 -- "expected output to contain: $needle"
    print -ru2 -- "actual output:"
    print -ru2 -- "$haystack"
    return 1
  fi
}

test_interactive_startup_registers_completion_and_hooks() {
  local tmp output

  tmp=$(mktemp -d)
  mkdir -p -- "${tmp}/home" "${tmp}/cache" "${tmp}/state"

  output="$(
    HOME="${tmp}/home" \
    ZDOTDIR="${repo_ngzsh_dir}/runcoms" \
    NGZSHDIR="$repo_ngzsh_dir" \
    XDG_CACHE_HOME="${tmp}/cache" \
    XDG_STATE_HOME="${tmp}/state" \
    zsh -ic '
      print -r -- "fpath-head=$fpath[1]"
      print -r -- "pre-cd=${_patcomps[(cd|chdir|pushd)]}"
      print -r -- "cd-comp=${_comps[cd]}"
      print -r -- "chdir-comp=${_comps[chdir]}"
      print -r -- "pushd-comp=${_comps[pushd]}"
      print -r -- "providers=${ng_cd_pre_completion_functions[*]}"
      print -r -- "winch=${ng_winch_functions[*]}"
      print -r -- "dump=$([[ -f "${NGZSH_CACHE_DIR}/.zcompdump" ]] && print yes || print no)"
    ' 2>&1
  )"

  assert_contains "$output" "fpath-head=${functions_dir}"
  assert_contains "$output" "pre-cd=_ng_cd_pre_complete"
  assert_contains "$output" "cd-comp=_cd"
  assert_contains "$output" "chdir-comp=_cd"
  assert_contains "$output" "pushd-comp=_cd"
  assert_contains "$output" "providers=ng-frequent-directories-complete"
  assert_contains "$output" "winch=ng-prompt-reset-on-winch"
  assert_contains "$output" "dump=yes"

  rm -rf -- "$tmp"
}

test_interactive_startup_registers_completion_and_hooks

print -r -- "startup tests passed"
