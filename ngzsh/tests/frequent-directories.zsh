#!/usr/bin/env zsh

emulate -L zsh
setopt err_return pipe_fail

zmodload zsh/zpty

typeset -r functions_dir="${0:A:h:h}/functions"
typeset -r tab=$'\t'

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

read_pty_output() {
  local pty_name="$1"
  local chunk output

  while zpty -r -t "$pty_name" chunk; do
    output+="$chunk"
  done

  print -rn -- "$output"
}

configure_completion_pty() {
  local pty_name="$1"
  local tmp="$2"
  local state_dir="$3"
  local db="$4"

  zpty -w "$pty_name" $'export TERM=dumb\n'
  zpty -w "$pty_name" "export HOME=${tmp}/home"$'\n'
  zpty -w "$pty_name" "export NGZSH_STATE_DIR=${state_dir}"$'\n'
  zpty -w "$pty_name" "export NG_FREQUENT_DIRECTORIES_DB=${db}"$'\n'
  zpty -w "$pty_name" "cd ${tmp}/home"$'\n'
  zpty -w "$pty_name" "fpath=(${functions_dir} \$fpath)"$'\n'
  zpty -w "$pty_name" $'autoload -Uz compinit; compinit -D -u\n'
  zpty -w "$pty_name" $'typeset -gaU ng_cd_pre_completion_functions\n'
  zpty -w "$pty_name" $'ng_cd_pre_completion_functions=(ng-frequent-directories-complete)\n'
  zpty -w "$pty_name" $'autoload -Uz _ng_cd_pre_complete ng-frequent-directories-complete\n'
  zpty -w "$pty_name" $'zstyle ":completion:*" group-name ""\n'
  zpty -w "$pty_name" $'zstyle ":completion:*:descriptions" format "-- %d --"\n'
  zpty -w "$pty_name" $'setopt AUTO_LIST AUTO_MENU AUTO_PARAM_SLASH\n'
  zpty -w "$pty_name" $'bindkey "^I" complete-word\n'
  zpty -w "$pty_name" $'PS1="PROMPT> "\n'
}

test_recording() {
  local tmp state_dir db

  tmp=$(mktemp -d)
  state_dir="${tmp}/state"
  db="${state_dir}/frequent-directories.tsv"

  mkdir -p -- "${tmp}/home/projects/dotfiles"

  (
    emulate -L zsh
    export NGZSH_STATE_DIR="$state_dir"
    export NG_FREQUENT_DIRECTORIES_DB="$db"
    fpath=("$functions_dir" $fpath)
    autoload -Uz ng-frequent-directories-add

    cd -- "${tmp}/home/projects/dotfiles"
    ng-frequent-directories-add
    ng-frequent-directories-add
  )

  assert_contains "$(<"$db")" "2${tab}${tmp}/home/projects/dotfiles"

  rm -rf -- "$tmp"
}

test_completion_group() {
  local tmp state_dir db output

  tmp=$(mktemp -d)
  state_dir="${tmp}/state"
  db="${state_dir}/frequent-directories.tsv"

  mkdir -p -- \
    "${tmp}/home/projects/dotfiles" \
    "${tmp}/home/work/docs" \
    "${tmp}/home/Documents" \
    "${tmp}/home/Downloads" \
    "$state_dir"

  {
    print -r -- "5${tab}${tmp}/home/projects/dotfiles"
    print -r -- "2${tab}${tmp}/home/work/docs"
  } > "$db"

  zpty frequent_directories_zsh zsh -f
  configure_completion_pty frequent_directories_zsh "$tmp" "$state_dir" "$db"

  sleep 0.5
  read_pty_output frequent_directories_zsh >/dev/null

  zpty -w frequent_directories_zsh $'cd do\t\t'
  sleep 0.5
  output="$(read_pty_output frequent_directories_zsh)"

  zpty -d frequent_directories_zsh

  assert_contains "$output" "-- frequent directories --"
  assert_contains "$output" "projects/dotfiles"
  assert_contains "$output" "work/docs"
  assert_contains "$output" "-- local directory --"

  rm -rf -- "$tmp"
}

test_completion_matches_last_segment() {
  local tmp state_dir db output

  tmp=$(mktemp -d)
  state_dir="${tmp}/state"
  db="${state_dir}/frequent-directories.tsv"

  mkdir -p -- \
    "${tmp}/home/projects/dotfiles" \
    "${tmp}/home/projects" \
    "$state_dir"

  {
    print -r -- "4${tab}${tmp}/home/projects/dotfiles"
    print -r -- "3${tab}${tmp}/home/projects"
  } > "$db"

  zpty frequent_directories_zsh zsh -f
  configure_completion_pty frequent_directories_zsh "$tmp" "$state_dir" "$db"

  sleep 0.5
  read_pty_output frequent_directories_zsh >/dev/null

  zpty -w frequent_directories_zsh $'cd proj\t\t'
  sleep 0.5
  output="$(read_pty_output frequent_directories_zsh)"

  zpty -d frequent_directories_zsh

  assert_contains "$output" "cd projects/"

  if [[ "$output" == *"projects/dotfiles"* ]]; then
    print -ru2 -- "expected last-segment matching to exclude dotfiles for query proj"
    print -ru2 -- "actual output:"
    print -ru2 -- "$output"
    return 1
  fi

  rm -rf -- "$tmp"
}

test_completion_leaves_directory_suffix() {
  local tmp state_dir db output

  tmp=$(mktemp -d)
  state_dir="${tmp}/state"
  db="${state_dir}/frequent-directories.tsv"

  mkdir -p -- "${tmp}/home/projects/dotfiles" "$state_dir"
  print -r -- "4${tab}${tmp}/home/projects/dotfiles" > "$db"

  zpty frequent_directories_zsh zsh -f
  configure_completion_pty frequent_directories_zsh "$tmp" "$state_dir" "$db"
  zpty -w frequent_directories_zsh $'setopt ALWAYS_TO_END\n'

  sleep 0.5
  read_pty_output frequent_directories_zsh >/dev/null

  zpty -w frequent_directories_zsh $'cd do\t\t\t'
  sleep 0.5
  output="$(read_pty_output frequent_directories_zsh)"

  zpty -d frequent_directories_zsh

  assert_contains "$output" "projects/dotfiles/"

  if [[ "$output" == *'(-/)'* ]]; then
    print -ru2 -- "expected accepted directory completion not to trigger cd replacement completion"
    print -ru2 -- "actual output:"
    print -ru2 -- "$output"
    return 1
  fi

  rm -rf -- "$tmp"
}

test_recording
test_completion_group
test_completion_matches_last_segment
test_completion_leaves_directory_suffix

print -r -- "frequent-directories tests passed"
