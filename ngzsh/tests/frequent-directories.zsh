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

assert_not_contains() {
  local haystack="$1"
  local needle="$2"

  if [[ "$haystack" == *"$needle"* ]]; then
    print -ru2 -- "expected output not to contain: $needle"
    print -ru2 -- "actual output:"
    print -ru2 -- "$haystack"
    return 1
  fi
}

assert_occurrences() {
  local haystack="$1"
  local needle="$2"
  integer expected="$3"
  integer actual=0
  local remainder="$haystack"

  while [[ "$remainder" == *"$needle"* ]]; do
    (( ++actual ))
    remainder="${remainder#*"$needle"}"
  done

  if (( actual != expected )); then
    print -ru2 -- "expected '$needle' to appear $expected times, found $actual"
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
  zpty -w "$pty_name" $'autoload -Uz ng-frequent-directories-complete ng-frequent-directories-jump\n'
  zpty -w "$pty_name" $'alias j=ng-frequent-directories-jump\n'
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

  mkdir -p -- "${tmp}/home/projects/alpha"

  (
    emulate -L zsh
    export NGZSH_STATE_DIR="$state_dir"
    export NG_FREQUENT_DIRECTORIES_DB="$db"
    fpath=("$functions_dir" $fpath)
    autoload -Uz ng-frequent-directories-add

    cd -- "${tmp}/home/projects/alpha"
    ng-frequent-directories-add
    ng-frequent-directories-add
  )

  assert_contains "$(<"$db")" "2${tab}${tmp}/home/projects/alpha"

  rm -rf -- "$tmp"
}

test_completion_group() {
  local tmp state_dir db output

  tmp=$(mktemp -d)
  state_dir="${tmp}/state"
  db="${state_dir}/frequent-directories.tsv"

  mkdir -p -- \
    "${tmp}/home/projects/alpha-lab" \
    "${tmp}/home/work/alpha-docs" \
    "${tmp}/home/archive" \
    "${tmp}/home/attic" \
    "$state_dir"

  {
    print -r -- "5${tab}${tmp}/home/projects/alpha-lab"
    print -r -- "2${tab}${tmp}/home/work/alpha-docs"
  } > "$db"

  zpty frequent_directories_zsh zsh -f
  configure_completion_pty frequent_directories_zsh "$tmp" "$state_dir" "$db"

  sleep 0.5
  read_pty_output frequent_directories_zsh >/dev/null

  zpty -w frequent_directories_zsh $'j al\t\t'
  sleep 0.5
  output="$(read_pty_output frequent_directories_zsh)"

  zpty -d frequent_directories_zsh

  assert_contains "$output" "-- frequent directories --"
  assert_contains "$output" "projects/alpha-lab"
  assert_contains "$output" "work/alpha-docs"

  rm -rf -- "$tmp"
}

test_completion_does_not_repeat_frequent_matches_as_corrections() {
  local tmp state_dir db output

  tmp=$(mktemp -d)
  state_dir="${tmp}/state"
  db="${state_dir}/frequent-directories.tsv"

  mkdir -p -- \
    "${tmp}/home/projects/echo-lab" \
    "${tmp}/home/data" \
    "$state_dir"

  print -r -- "5${tab}${tmp}/home/projects/echo-lab" > "$db"

  zpty frequent_directories_zsh zsh -f
  configure_completion_pty frequent_directories_zsh "$tmp" "$state_dir" "$db"
  zpty -w frequent_directories_zsh $'zstyle ":completion:*" completer _complete _approximate\n'

  sleep 0.5
  read_pty_output frequent_directories_zsh >/dev/null

  zpty -w frequent_directories_zsh $'j la\t\t'
  sleep 0.5
  output="$(read_pty_output frequent_directories_zsh)"

  zpty -d frequent_directories_zsh

  assert_contains "$output" "-- frequent directories --"
  assert_contains "$output" "-- corrections --"
  assert_occurrences "$output" "-- frequent directories --" 1
  assert_occurrences "$output" "-- corrections --" 1

  rm -rf -- "$tmp"
}

test_completion_uses_cdpath_relative_spelling() {
  local tmp state_dir db output

  tmp=$(mktemp -d)
  state_dir="${tmp}/state"
  db="${state_dir}/frequent-directories.tsv"

  mkdir -p -- \
    "${tmp}/home/base/team/atlas" \
    "${tmp}/home/workspace/group/atlas" \
    "$state_dir"

  print -r -- "6${tab}${tmp}/home/workspace/group/atlas" > "$db"

  zpty frequent_directories_zsh zsh -f
  configure_completion_pty frequent_directories_zsh "$tmp" "$state_dir" "$db"
  zpty -w frequent_directories_zsh "cd ${tmp}/home/base"$'\n'
  zpty -w frequent_directories_zsh "cdpath=(. ${tmp}/home/workspace)"$'\n'

  sleep 0.5
  read_pty_output frequent_directories_zsh >/dev/null

  zpty -w frequent_directories_zsh $'j at\t\t\t'
  sleep 0.5
  output="$(read_pty_output frequent_directories_zsh)"

  zpty -d frequent_directories_zsh

  assert_contains "$output" "group/atlas/"

  if [[ "$output" == *"${tmp}/home/workspace/group/atlas"* ]]; then
    print -ru2 -- "expected cdpath-relative spelling instead of absolute spelling"
    print -ru2 -- "actual output:"
    print -ru2 -- "$output"
    return 1
  fi

  rm -rf -- "$tmp"
}

test_completion_uses_cdpath_roots_with_spaces_and_symlinks() {
  local tmp state_dir db output space_root real_root link_root

  tmp=$(mktemp -d)
  state_dir="${tmp}/state"
  db="${state_dir}/frequent-directories.tsv"
  space_root="${tmp}/space root"
  real_root="${tmp}/real-root"
  link_root="${tmp}/link-root"

  mkdir -p -- \
    "${tmp}/home/base" \
    "${space_root}/group/atlas" \
    "${real_root}/group/aurora" \
    "$state_dir"
  ln -s -- "$real_root" "$link_root"

  {
    print -r -- "6${tab}${space_root}/group/atlas"
    print -r -- "5${tab}${real_root}/group/aurora"
  } > "$db"

  zpty frequent_directories_zsh zsh -f
  configure_completion_pty frequent_directories_zsh "$tmp" "$state_dir" "$db"
  zpty -w frequent_directories_zsh "cd ${tmp}/home/base"$'\n'
  zpty -w frequent_directories_zsh "cdpath=(${(q)space_root} ${(q)link_root} .)"$'\n'

  sleep 0.5
  read_pty_output frequent_directories_zsh >/dev/null

  zpty -w frequent_directories_zsh $'j at\t\nprint -r -- SPACE:${PWD:A}\ncd "$HOME/base"\nj au\t\nprint -r -- LINK:${PWD:A}\n'
  sleep 0.8
  output="$(read_pty_output frequent_directories_zsh)"

  zpty -d frequent_directories_zsh

  assert_contains "$output" "SPACE:${space_root}/group/atlas"
  assert_contains "$output" "LINK:${real_root}/group/aurora"

  rm -rf -- "$tmp"
}

test_completion_rejects_ambiguous_cdpath_spelling() {
  local tmp state_dir db output

  tmp=$(mktemp -d)
  state_dir="${tmp}/state"
  db="${state_dir}/frequent-directories.tsv"

  mkdir -p -- \
    "${tmp}/home/base" \
    "${tmp}/first/team/atlas" \
    "${tmp}/second/team/atlas" \
    "$state_dir"

  print -r -- "6${tab}${tmp}/second/team/atlas" > "$db"

  zpty frequent_directories_zsh zsh -f
  configure_completion_pty frequent_directories_zsh "$tmp" "$state_dir" "$db"
  zpty -w frequent_directories_zsh "cd ${tmp}/home/base"$'\n'
  zpty -w frequent_directories_zsh "cdpath=(${tmp}/first ${tmp}/second .)"$'\n'

  sleep 0.5
  read_pty_output frequent_directories_zsh >/dev/null

  zpty -w frequent_directories_zsh $'j at\t\t\t\nprint -r -- PWD:${PWD:A}\n'
  sleep 0.5
  output="$(read_pty_output frequent_directories_zsh)"

  zpty -d frequent_directories_zsh

  assert_contains "$output" "${tmp}/second/team/atlas/"
  assert_not_contains "$output" "j team/atlas"
  assert_contains "$output" "PWD:${tmp}/second/team/atlas"

  rm -rf -- "$tmp"
}

test_completion_uses_home_relative_fallback() {
  local tmp state_dir db output

  tmp=$(mktemp -d)
  state_dir="${tmp}/state"
  db="${state_dir}/frequent-directories.tsv"

  mkdir -p -- "${tmp}/home/base" "${tmp}/home/archive/aurora" "$state_dir"
  print -r -- "7${tab}${tmp}/home/archive/aurora" > "$db"

  zpty frequent_directories_zsh zsh -f
  configure_completion_pty frequent_directories_zsh "$tmp" "$state_dir" "$db"
  zpty -w frequent_directories_zsh "cd ${tmp}/home/base"$'\n'
  zpty -w frequent_directories_zsh "cdpath=(.)"$'\n'

  sleep 0.5
  read_pty_output frequent_directories_zsh >/dev/null

  zpty -w frequent_directories_zsh $'j au\t\t\t'
  sleep 0.5
  output="$(read_pty_output frequent_directories_zsh)"

  zpty -d frequent_directories_zsh

  assert_contains "$output" "~/archive/aurora/"

  if [[ "$output" == *"${tmp}/home/archive/aurora"* ]]; then
    print -ru2 -- "expected home-relative spelling instead of absolute spelling"
    print -ru2 -- "actual output:"
    print -ru2 -- "$output"
    return 1
  fi

  rm -rf -- "$tmp"
}

test_completion_preserves_qualified_parent() {
  local tmp state_dir db output

  tmp=$(mktemp -d)
  state_dir="${tmp}/state"
  db="${state_dir}/frequent-directories.tsv"

  mkdir -p -- \
    "${tmp}/home/base/team/atlas" \
    "${tmp}/home/base/other/atlas" \
    "$state_dir"

  {
    print -r -- "9${tab}${tmp}/home/base/other/atlas"
    print -r -- "4${tab}${tmp}/home/base/team/atlas"
  } > "$db"

  zpty frequent_directories_zsh zsh -f
  configure_completion_pty frequent_directories_zsh "$tmp" "$state_dir" "$db"
  zpty -w frequent_directories_zsh "cd ${tmp}/home/base"$'\n'

  sleep 0.5
  read_pty_output frequent_directories_zsh >/dev/null

  zpty -w frequent_directories_zsh $'j team/at\t\t'
  sleep 0.5
  output="$(read_pty_output frequent_directories_zsh)"

  zpty -d frequent_directories_zsh

  assert_contains "$output" "team/atlas/"
  assert_not_contains "$output" "other/atlas"

  rm -rf -- "$tmp"
}

test_completion_preserves_explicit_qualified_parents() {
  local tmp state_dir db output

  tmp=$(mktemp -d)
  state_dir="${tmp}/state"
  db="${state_dir}/frequent-directories.tsv"

  mkdir -p -- \
    "${tmp}/home/base/team/atlas" \
    "${tmp}/home/base/sibling" \
    "${tmp}/home/team/atlas" \
    "${tmp}/abs/team/atlas" \
    "$state_dir"

  {
    print -r -- "9${tab}${tmp}/home/base/team/atlas"
    print -r -- "8${tab}${tmp}/home/team/atlas"
    print -r -- "7${tab}${tmp}/abs/team/atlas"
  } > "$db"

  zpty frequent_directories_zsh zsh -f
  configure_completion_pty frequent_directories_zsh "$tmp" "$state_dir" "$db"
  zpty -w frequent_directories_zsh "cd ${tmp}/home/base"$'\n'

  sleep 0.5
  read_pty_output frequent_directories_zsh >/dev/null

  zpty -w frequent_directories_zsh $'j ./team/at\t\nprint -r -- DOT:${PWD:A}\n'
  zpty -w frequent_directories_zsh "cd ${tmp}/home/base/sibling"$'\n'
  zpty -w frequent_directories_zsh $'j ../team/at\t\nprint -r -- DOTDOT:${PWD:A}\n'
  zpty -w frequent_directories_zsh "cd ${tmp}/home/base"$'\n'
  zpty -w frequent_directories_zsh $'j ~/team/at\t\nprint -r -- HOME:${PWD:A}\n'
  zpty -w frequent_directories_zsh "cd ${tmp}/home/base"$'\n'
  zpty -w frequent_directories_zsh "j ${tmp}/abs/team/at"$'\t\n'
  zpty -w frequent_directories_zsh $'print -r -- ABS:${PWD:A}\n'
  sleep 1
  output="$(read_pty_output frequent_directories_zsh)"

  zpty -d frequent_directories_zsh

  assert_contains "$output" "DOT:${tmp}/home/base/team/atlas"
  assert_contains "$output" "DOTDOT:${tmp}/home/base/team/atlas"
  assert_contains "$output" "HOME:${tmp}/home/team/atlas"
  assert_contains "$output" "ABS:${tmp}/abs/team/atlas"

  rm -rf -- "$tmp"
}

test_completion_preserves_cdpath_qualified_parent() {
  local tmp state_dir db output cdpath_root

  tmp=$(mktemp -d)
  state_dir="${tmp}/state"
  db="${state_dir}/frequent-directories.tsv"
  cdpath_root="${tmp}/workspace"

  mkdir -p -- \
    "${tmp}/home/base" \
    "${cdpath_root}/team/atlas" \
    "$state_dir"

  print -r -- "9${tab}${cdpath_root}/team/atlas" > "$db"

  zpty frequent_directories_zsh zsh -f
  configure_completion_pty frequent_directories_zsh "$tmp" "$state_dir" "$db"
  zpty -w frequent_directories_zsh "cd ${tmp}/home/base"$'\n'
  zpty -w frequent_directories_zsh "cdpath=(${(q)cdpath_root} .)"$'\n'

  sleep 0.5
  read_pty_output frequent_directories_zsh >/dev/null

  zpty -w frequent_directories_zsh $'j team/at\t\nprint -r -- CDPATH_PARENT:${PWD:A}\n'
  sleep 0.5
  output="$(read_pty_output frequent_directories_zsh)"

  zpty -d frequent_directories_zsh

  assert_contains "$output" "CDPATH_PARENT:${cdpath_root}/team/atlas"

  rm -rf -- "$tmp"
}

test_completion_honors_options_and_double_dash() {
  local tmp state_dir db output expected_pwd

  tmp=$(mktemp -d)
  state_dir="${tmp}/state"
  db="${state_dir}/frequent-directories.tsv"

  mkdir -p -- "${tmp}/home/projects/atlas" "$state_dir"
  print -r -- "7${tab}${tmp}/home/projects/atlas" > "$db"

  zpty frequent_directories_zsh zsh -f
  configure_completion_pty frequent_directories_zsh "$tmp" "$state_dir" "$db"

  sleep 0.5
  read_pty_output frequent_directories_zsh >/dev/null

  zpty -w frequent_directories_zsh $'j -P at\t\nprint -r -- PWD:${PWD:A}\ncd "$HOME"\nj -- at\t\nprint -r -- PWD:${PWD:A}\n'
  sleep 0.8
  output="$(read_pty_output frequent_directories_zsh)"

  zpty -d frequent_directories_zsh

  expected_pwd="${tmp}/home/projects/atlas"
  assert_contains "$output" "PWD:${expected_pwd:A}"
  assert_not_contains "$output" "cd: no such file or directory"

  rm -rf -- "$tmp"
}

test_completion_matches_last_segment() {
  local tmp state_dir db output

  tmp=$(mktemp -d)
  state_dir="${tmp}/state"
  db="${state_dir}/frequent-directories.tsv"

  mkdir -p -- \
    "${tmp}/home/projects/portal" \
    "${tmp}/home/projects" \
    "$state_dir"

  {
    print -r -- "4${tab}${tmp}/home/projects/portal"
    print -r -- "3${tab}${tmp}/home/projects"
  } > "$db"

  zpty frequent_directories_zsh zsh -f
  configure_completion_pty frequent_directories_zsh "$tmp" "$state_dir" "$db"

  sleep 0.5
  read_pty_output frequent_directories_zsh >/dev/null

  zpty -w frequent_directories_zsh $'j proj\t\t'
  sleep 0.5
  output="$(read_pty_output frequent_directories_zsh)"

  zpty -d frequent_directories_zsh

  assert_contains "$output" "j projects/"

  if [[ "$output" == *"projects/portal"* ]]; then
    print -ru2 -- "expected last-segment matching to exclude portal for query proj"
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

  mkdir -p -- "${tmp}/home/projects/atlas" "$state_dir"
  print -r -- "4${tab}${tmp}/home/projects/atlas" > "$db"

  zpty frequent_directories_zsh zsh -f
  configure_completion_pty frequent_directories_zsh "$tmp" "$state_dir" "$db"
  zpty -w frequent_directories_zsh $'setopt ALWAYS_TO_END\n'

  sleep 0.5
  read_pty_output frequent_directories_zsh >/dev/null

  zpty -w frequent_directories_zsh $'j at\t\t\t'
  sleep 0.5
  output="$(read_pty_output frequent_directories_zsh)"

  zpty -d frequent_directories_zsh

  assert_contains "$output" "projects/atlas/"

  if [[ "$output" == *'(-/)'* ]]; then
    print -ru2 -- "expected accepted directory completion not to trigger replacement completion"
    print -ru2 -- "actual output:"
    print -ru2 -- "$output"
    return 1
  fi

  rm -rf -- "$tmp"
}

test_completion_continues_inside_accepted_frequent_directory() {
  local tmp state_dir db output

  tmp=$(mktemp -d)
  state_dir="${tmp}/state"
  db="${state_dir}/frequent-directories.tsv"

  mkdir -p -- "${tmp}/home/projects/atlas/child" "$state_dir"
  print -r -- "4${tab}${tmp}/home/projects/atlas" > "$db"

  zpty frequent_directories_zsh zsh -f
  configure_completion_pty frequent_directories_zsh "$tmp" "$state_dir" "$db"
  zpty -w frequent_directories_zsh $'setopt ALWAYS_TO_END\n'

  sleep 0.5
  read_pty_output frequent_directories_zsh >/dev/null

  zpty -w frequent_directories_zsh $'j at\tch\t\nprint -r -- PWD:${PWD:A}\n'
  sleep 0.5
  output="$(read_pty_output frequent_directories_zsh)"

  zpty -d frequent_directories_zsh

  assert_contains "$output" "PWD:${tmp}/home/projects/atlas/child"

  if [[ "$output" == *'(-/)'* || "$output" == *'//child'* ]]; then
    print -ru2 -- "expected continued completion without replacement or duplicate-slash artifacts"
    print -ru2 -- "actual output:"
    print -ru2 -- "$output"
    return 1
  fi

  rm -rf -- "$tmp"
}

test_completion_executes_path_with_special_characters() {
  local tmp state_dir db output expected_pwd

  tmp=$(mktemp -d)
  state_dir="${tmp}/state"
  db="${state_dir}/frequent-directories.tsv"

  mkdir -p -- "${tmp}/home/base" "${tmp}/home/archive/spark [one] (draft)" "$state_dir"
  print -r -- "7${tab}${tmp}/home/archive/spark [one] (draft)" > "$db"

  zpty frequent_directories_zsh zsh -f
  configure_completion_pty frequent_directories_zsh "$tmp" "$state_dir" "$db"
  zpty -w frequent_directories_zsh "cd ${tmp}/home/base"$'\n'
  zpty -w frequent_directories_zsh "cdpath=(.)"$'\n'

  sleep 0.5
  read_pty_output frequent_directories_zsh >/dev/null

  zpty -w frequent_directories_zsh $'j sp\t\nprint -r -- PWD:${PWD:A}\n'
  sleep 0.5
  output="$(read_pty_output frequent_directories_zsh)"

  zpty -d frequent_directories_zsh

  expected_pwd="${tmp}/home/archive/spark [one] (draft)"
  assert_contains "$output" "PWD:${expected_pwd:A}"

  rm -rf -- "$tmp"
}

test_completion_executes_absolute_fallback() {
  local tmp state_dir db output expected_pwd

  tmp=$(mktemp -d)
  state_dir="${tmp}/state"
  db="${state_dir}/frequent-directories.tsv"

  mkdir -p -- "${tmp}/home/base" "${tmp}/outside/atlas" "$state_dir"
  print -r -- "7${tab}${tmp}/outside/atlas" > "$db"

  zpty frequent_directories_zsh zsh -f
  configure_completion_pty frequent_directories_zsh "$tmp" "$state_dir" "$db"
  zpty -w frequent_directories_zsh "cd ${tmp}/home/base"$'\n'
  zpty -w frequent_directories_zsh "cdpath=(.)"$'\n'

  sleep 0.5
  read_pty_output frequent_directories_zsh >/dev/null

  zpty -w frequent_directories_zsh $'j at\t\nprint -r -- PWD:${PWD:A}\n'
  sleep 0.5
  output="$(read_pty_output frequent_directories_zsh)"

  zpty -d frequent_directories_zsh

  expected_pwd="${tmp}/outside/atlas"
  assert_contains "$output" "PWD:${expected_pwd:A}"

  rm -rf -- "$tmp"
}

test_completion_does_not_leave_helper_functions() {
  local tmp state_dir db output

  tmp=$(mktemp -d)
  state_dir="${tmp}/state"
  db="${state_dir}/frequent-directories.tsv"

  mkdir -p -- "${tmp}/home/projects/atlas" "$state_dir"
  print -r -- "7${tab}${tmp}/home/projects/atlas" > "$db"

  zpty frequent_directories_zsh zsh -f
  configure_completion_pty frequent_directories_zsh "$tmp" "$state_dir" "$db"

  sleep 0.5
  read_pty_output frequent_directories_zsh >/dev/null

  zpty -w frequent_directories_zsh $'j at\t\nprint -r -- helper:${+functions[_frequent_directories_complete_resolves_to]}:${+functions[_frequent_directories_complete_add_matches]}\n'
  sleep 0.5
  output="$(read_pty_output frequent_directories_zsh)"

  zpty -d frequent_directories_zsh

  assert_contains "$output" "helper:0:0"

  rm -rf -- "$tmp"
}

test_recording
test_completion_group
test_completion_does_not_repeat_frequent_matches_as_corrections
test_completion_uses_cdpath_relative_spelling
test_completion_uses_cdpath_roots_with_spaces_and_symlinks
test_completion_rejects_ambiguous_cdpath_spelling
test_completion_uses_home_relative_fallback
test_completion_preserves_qualified_parent
test_completion_preserves_explicit_qualified_parents
test_completion_preserves_cdpath_qualified_parent
test_completion_honors_options_and_double_dash
test_completion_matches_last_segment
test_completion_leaves_directory_suffix
test_completion_continues_inside_accepted_frequent_directory
test_completion_executes_path_with_special_characters
test_completion_executes_absolute_fallback
test_completion_does_not_leave_helper_functions

print -r -- "frequent-directories tests passed"
