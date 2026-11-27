#!/usr/bin/env zsh

emulate -L zsh
setopt err_return pipe_fail
zmodload zsh/zpty

typeset -r repo_ngzsh_dir="${0:A:h:h}"
typeset -gA NG_HISTORY_TEST_STATE
typeset -g NG_HISTORY_TEST_DISK NG_HISTORY_TEST_MEMORY

typeset -r example_history=$': 1700000000:1;example first\n: 1700000001:1;example last\n'
typeset -r example_edit=$': 1700000000:1;example first\n: 1700000002:1;example edited\n'
typeset -r example_append=$': 1700000010:1;example elsewhere\n'

ng-history-test-equals() {
  [[ "$1" == "$2" ]] && return 0
  print -ru2 -- "expected: ${(qqq)2}"
  print -ru2 -- "actual: ${(qqq)1}"
  return 1
}

ng-history-test-read() {
  REPLY="$(cat -- "$1"; print -rn -- .)"
  REPLY=${REPLY%.}
}

ng-history-test-wait() {
  local file="$1" marker="$2" chunk output
  integer attempt
  for attempt in {1..100}; do
    [[ -f "$file" && "$(<"$file")" == *"$marker"* ]] && return 0
    while zpty -r -t ng_history_test chunk; do
      output+="$chunk"
    done
    sleep 0.05
  done
  print -ru2 -- "history probe timed out: $output"
  return 1
}

ng-history-test-probe() {
  local mode="$1" before="$2" edited="$3" keys="$4" after_keys="$5"
  local settings="${6:-HISTSIZE=100000 SAVEHIST=100000}" REPLY
  local disk_append="${7:-}"
  local disk_state="${8:-present}"
  local tmp line editor_command
  local -a files
  tmp=$(mktemp -d)
  {
    print -rn -- "$before" > "$tmp/history"
    print -rn -- "$edited" > "$tmp/edited"
    print -rn -- "$disk_append" > "$tmp/disk-append"
    print -r -- "$mode" > "$tmp/mode"
    cp "$repo_ngzsh_dir/tests/fixtures/history-editor.py" "$tmp/editor with spaces"
    chmod +x "$tmp/editor with spaces"
    editor_command="${(qq)tmp}/'editor with spaces' --example-option"
    print -r -- '["--example-option"]' > "$tmp/options"
    if [[ "$mode" == simple-command ]]; then
      editor_command="${(qq)tmp}/'editor with spaces'"
      print -r -- '[]' > "$tmp/options"
    elif [[ "$mode" == quoted-argument ]]; then
      editor_command="${(qq)tmp}/'editor with spaces' '--example option'"
      print -r -- '["--example option"]' > "$tmp/options"
    fi
    if [[ "$mode" == launch-failure ]]; then
      editor_command="${(qq)tmp}/missing-editor"
    fi
    if [[ "$mode" == save-failure ]]; then
      mkdir "$tmp/bin"
      print -r -- '#!/bin/sh' 'exit 1' > "$tmp/bin/mv"
      chmod +x "$tmp/bin/mv"
    fi
    cat > "$tmp/setup.zsh" <<SETUP
NGZSH_STATE_DIR=${(q)tmp}
fpath=(${(q)repo_ngzsh_dir}/functions \$fpath)
source ${(q)repo_ngzsh_dir}/interactive/history.zsh
source ${(q)repo_ngzsh_dir}/interactive/editor.zsh
EDITOR=${(q)editor_command}
VISUAL=/missing-example-visual
NG_HISTORY_TEST_ROOT=${(q)tmp}
NG_HISTORY_TEST_DISK_STATE=${(q)disk_state}
PATH=${(q)tmp}/bin:\$PATH
$settings
SETUP
    [[ "$mode" == prepare-failure ]] && print -r -- 'HISTFILE="$NG_HISTORY_TEST_ROOT/missing/history"' >> "$tmp/setup.zsh"
    cat >> "$tmp/setup.zsh" <<'SETUP'
ng-history-test-ready() {
  zle ng-editor-info
  local history_file=$HISTFILE
  fc -p "$NG_HISTORY_TEST_ROOT/history" "$HISTSIZE" "$SAVEHIST"
  HISTFILE=$history_file
  cat "$NG_HISTORY_TEST_ROOT/disk-append" >> "$NG_HISTORY_TEST_ROOT/history"
  case $NG_HISTORY_TEST_DISK_STATE in
    missing) mv "$NG_HISTORY_TEST_ROOT/history" "$NG_HISTORY_TEST_ROOT/seed" ;;
    unreadable) HISTFILE="$NG_HISTORY_TEST_ROOT/unreadable"; ln -s "$HISTFILE.missing" "$HISTFILE" ;;
    unset) unset HISTFILE ;;
  esac
  print ready > "$NG_HISTORY_TEST_ROOT/ready"
}
zle -N zle-line-init ng-history-test-ready
ng-history-test-capture() {
  print -rn -- "$BUFFER" > "$NG_HISTORY_TEST_ROOT/buffer"
  fc -W "$NG_HISTORY_TEST_ROOT/memory"
  print -r -- "size=$HISTSIZE
save=$SAVEHIST
shared=$options[sharehistory]
cursor=$CURSOR
done" > "$NG_HISTORY_TEST_ROOT/result"
}
zle -N ng-history-test-capture
bindkey -M viins '^X^T' ng-history-test-capture
bindkey -M vicmd '^X^T' ng-history-test-capture
SETUP
    zpty ng_history_test env TERM=xterm-256color zsh -f
    zpty -w ng_history_test " source ${(q)tmp}/setup.zsh"
    ng-history-test-wait "$tmp/ready" ready
    zpty -w -n ng_history_test "$keys"$'\x18\x08'
    if [[ "$mode" == interactive ]]; then
      ng-history-test-wait "$tmp/editor-ready" ready
      zpty -w -n ng_history_test $'save example edit\n'
    fi
    zpty -w -n ng_history_test "$after_keys"$'\x18\x14'
    ng-history-test-wait "$tmp/result" done

    NG_HISTORY_TEST_STATE=()
    while IFS= read -r line; do
      [[ "$line" == *=* ]] && NG_HISTORY_TEST_STATE[${line%%=*}]="${line#*=}"
    done < "$tmp/result"
    ng-history-test-read "$tmp/buffer"
    NG_HISTORY_TEST_STATE[buffer]=$REPLY
    NG_HISTORY_TEST_DISK=''
    NG_HISTORY_TEST_STATE[disk_exists]=no
    if [[ -f "$tmp/history" ]]; then
      ng-history-test-read "$tmp/history"
      NG_HISTORY_TEST_DISK=$REPLY
      NG_HISTORY_TEST_STATE[disk_exists]=yes
    fi
    NG_HISTORY_TEST_MEMORY=''
    while IFS= read -r line; do
      [[ $line == ': '<->':'<->';' ]] && continue
      NG_HISTORY_TEST_MEMORY+="$line"$'\n'
    done < "$tmp/memory"
    files=( "$tmp"/history.edit.*(N) )
    NG_HISTORY_TEST_STATE[recovery_count]=${#files}
    files=( "$tmp"/history.snapshot.*(N) )
    NG_HISTORY_TEST_STATE[snapshot_count]=${#files}
    NG_HISTORY_TEST_STATE[editor_input]=''
    NG_HISTORY_TEST_STATE[editor_opened]=no
    if [[ -f "$tmp/editor-input" ]]; then
      NG_HISTORY_TEST_STATE[editor_opened]=yes
      ng-history-test-read "$tmp/editor-input"
      NG_HISTORY_TEST_STATE[editor_input]=$REPLY
    fi
  } always {
    zpty -d ng_history_test 2>/dev/null || true
    rm -rf -- "$tmp"
  }
}

ng-history-test-saved-content() {
  local before after
  local -a cases=(
    "$example_history" "$example_edit"
    '' "$example_edit"
    "$example_history" "$example_history"
    $': 1700000000:1;example [*]? $HOME `pwd` \\path\n: 1700000001:1;example multiline\\\nsecond line\n'
    $': 1700000000:1;example [*]? $HOME `pwd` \\path\n: 1700000001:1;example multiline\\\nsecond line\n'
    $': 1700000000:1;example first\n: 1700000001:1;discard one\n: 1700000002:1;discard multiline\\\nsecond line\n: 1700000003:1;discard [*]?\n: 1700000004:1;example last\n'
    $': 1700000000:1;example first\n: 1700000004:1;example last\n'
  )
  while (( ${#cases} )); do
    before=$cases[1] after=$cases[2]
    shift 2 cases
    ng-history-test-probe save "$before" "$after" '' ''
    ng-history-test-equals "$NG_HISTORY_TEST_DISK" "$after"
    ng-history-test-equals "$NG_HISTORY_TEST_MEMORY" "$after"
  done
}

ng-history-test-editor-input() {
  local disk_append
  for disk_append in '' "$example_append"; do
    ng-history-test-probe save "$example_history" "$example_edit" '' '' '' "$disk_append"
    ng-history-test-equals "${NG_HISTORY_TEST_STATE[editor_input]}" "$example_history$disk_append"
  done
}

ng-history-test-missing-file() {
  local mode exists disk memory
  local concurrent_history=$': 1700000010:1;example concurrent\n'
  for mode exists disk memory in \
    save yes "$example_edit" "$example_edit" \
    editor-failure no '' "$example_history" \
    concurrent yes "$concurrent_history" "$example_history"; do
    ng-history-test-probe "$mode" "$example_history" "$example_edit" '' '' '' '' missing
    ng-history-test-equals "${NG_HISTORY_TEST_STATE[editor_input]}" "$example_history"
    ng-history-test-equals "${NG_HISTORY_TEST_STATE[disk_exists]}" "$exists"
    ng-history-test-equals "$NG_HISTORY_TEST_DISK" "$disk"
    ng-history-test-equals "$NG_HISTORY_TEST_MEMORY" "$memory"
    ng-history-test-equals "${NG_HISTORY_TEST_STATE[recovery_count]}" 0
  done
}

ng-history-test-unavailable-file() {
  local disk_state
  for disk_state in unset unreadable; do
    ng-history-test-probe save "$example_history" "$example_edit" '' '' '' '' "$disk_state"
    ng-history-test-equals "${NG_HISTORY_TEST_STATE[editor_opened]}" no
    ng-history-test-equals "$NG_HISTORY_TEST_DISK" "$example_history"
    ng-history-test-equals "$NG_HISTORY_TEST_MEMORY" "$example_history"
  done
}

ng-history-test-editor-command() {
  local mode
  for mode in simple-command save quoted-argument; do
    ng-history-test-probe "$mode" "$example_history" "$example_edit" '' ''
    ng-history-test-equals "$NG_HISTORY_TEST_DISK" "$example_edit"
  done
}

ng-history-test-prompt-preserved() {
  local keys cursor
  for keys cursor in 'example prompt' 14 $'example prompt\e' 13; do
    ng-history-test-probe save "$example_history" "$example_edit" "$keys" ''
    ng-history-test-equals "${NG_HISTORY_TEST_STATE[buffer]}" 'example prompt'
    ng-history-test-equals "${NG_HISTORY_TEST_STATE[cursor]}" "$cursor"
  done
}

ng-history-test-settings-preserved() {
  local settings size save shared
  for settings size save shared in \
    'HISTSIZE=100000 SAVEHIST=100000' 100000 100000 on \
    'HISTSIZE=40 SAVEHIST=20; unsetopt share_history' 40 20 off; do
    ng-history-test-probe save "$example_history" "$example_edit" '' '' "$settings"
    ng-history-test-equals "${NG_HISTORY_TEST_STATE[size]}" "$size"
    ng-history-test-equals "${NG_HISTORY_TEST_STATE[save]}" "$save"
    ng-history-test-equals "${NG_HISTORY_TEST_STATE[shared]}" "$shared"
  done
}

ng-history-test-navigation() {
  local keys expected
  for keys expected in $'\e[A' 'example edited' $'example\e[A' 'example edited'; do
    ng-history-test-probe save "$example_history" "$example_edit" '' "$keys"
    ng-history-test-equals "${NG_HISTORY_TEST_STATE[buffer]}" "$expected"
  done
}

ng-history-test-failure-preserves-history() {
  local mode disk_append
  for mode in prepare-failure launch-failure editor-failure save-failure; do
    for disk_append in '' "$example_append"; do
      ng-history-test-probe "$mode" "$example_history" "$example_edit" 'example prompt' '' '' "$disk_append"
      ng-history-test-equals "$NG_HISTORY_TEST_DISK" "$example_history$disk_append"
      ng-history-test-equals "$NG_HISTORY_TEST_MEMORY" "$example_history"
      ng-history-test-equals "${NG_HISTORY_TEST_STATE[buffer]}" 'example prompt'
    done
  done
}

ng-history-test-temporary-files() {
  local mode
  for mode in save prepare-failure launch-failure editor-failure save-failure concurrent; do
    ng-history-test-probe "$mode" "$example_history" "$example_edit" '' ''
    ng-history-test-equals "${NG_HISTORY_TEST_STATE[recovery_count]}" 0
    ng-history-test-equals "${NG_HISTORY_TEST_STATE[snapshot_count]}" 0
  done
}

ng-history-test-concurrent-write-preserved() {
  ng-history-test-probe concurrent "$example_history" "$example_edit" '' ''
  ng-history-test-equals "$NG_HISTORY_TEST_DISK" "$example_history"$': 1700000010:1;example concurrent\n'
  ng-history-test-equals "$NG_HISTORY_TEST_MEMORY" "$example_history"
}

ng-history-test-preserves-nonempty-history() {
  local edited
  for edited in '' $' \n\n'; do
    ng-history-test-probe save "$example_history" "$edited" '' ''
    ng-history-test-equals "$NG_HISTORY_TEST_DISK" "$example_history"
    ng-history-test-equals "$NG_HISTORY_TEST_MEMORY" "$example_history"
    ng-history-test-equals "${NG_HISTORY_TEST_STATE[recovery_count]}" 0
  done
}

ng-history-test-interactive-editor() {
  ng-history-test-probe interactive "$example_history" "$example_edit" 'example' ' prompt'
  ng-history-test-equals "$NG_HISTORY_TEST_DISK" "$example_edit"
  ng-history-test-equals "${NG_HISTORY_TEST_STATE[buffer]}" 'example prompt'
}

ng-history-test-editor-input
ng-history-test-missing-file
ng-history-test-unavailable-file
ng-history-test-editor-command
ng-history-test-saved-content
ng-history-test-prompt-preserved
ng-history-test-settings-preserved
ng-history-test-navigation
ng-history-test-failure-preserves-history
ng-history-test-temporary-files
ng-history-test-concurrent-write-preserved
ng-history-test-preserves-nonempty-history
ng-history-test-interactive-editor
print -r -- 'history tests passed'
