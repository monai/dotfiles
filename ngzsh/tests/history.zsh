#!/usr/bin/env zsh

emulate -L zsh
setopt err_return pipe_fail
zmodload zsh/zpty

typeset -r repo_ngzsh_dir="${0:A:h:h}"
typeset -gA NG_HISTORY_TEST_STATE
typeset -g NG_HISTORY_TEST_DISK NG_HISTORY_TEST_MEMORY NG_HISTORY_TEST_BEFORE

ng-history-test-equals() {
  [[ "$1" == "$2" ]] && return 0
  print -ru2 -- "expected: $2"
  print -ru2 -- "actual: $1"
  return 1
}

ng-history-test-contains() {
  [[ "$1" == *"$2"* ]] && return 0
  print -ru2 -- "missing: $2"
  return 1
}

ng-history-test-excludes() {
  [[ "$1" != *"$2"* ]] && return 0
  print -ru2 -- "unexpected: $2"
  return 1
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
  local target="$1" keys="$2" after_keys="$3" failure="$4"
  shift 4
  local tmp entry serialized line
  integer timestamp=1700000000
  tmp=$(mktemp -d)
  {
    for entry in "$@"; do
      serialized="${entry//$'\n'/$'\\\n'}"
      print -r -- ": $timestamp:1;$serialized"
      (( timestamp++ ))
    done > "$tmp/history"

    cat > "$tmp/setup.zsh" <<EOF
NGZSH_STATE_DIR=${(q)tmp}
fpath=(${(q)repo_ngzsh_dir}/functions \$fpath)
source ${(q)repo_ngzsh_dir}/interactive/history.zsh
source ${(q)repo_ngzsh_dir}/interactive/editor.zsh
fc -R "\$HISTFILE"
NG_HISTORY_TEST_TARGET=${(q)target}
NG_HISTORY_TEST_ROOT=${(q)tmp}
EOF
    cat >> "$tmp/setup.zsh" <<'EOF'
ng-history-test-ready() {
  zle ng-editor-info
  command cp "$NG_HISTORY_TEST_ROOT/history" "$NG_HISTORY_TEST_ROOT/before"
  print ready > "$NG_HISTORY_TEST_ROOT/ready"
}
zle -N zle-line-init ng-history-test-ready
ng-history-test-capture() {
  local entry
  integer found=0
  for entry in "${(@v)history}"; do
    [[ "$entry" == "$NG_HISTORY_TEST_TARGET" ]] && (( found++ ))
  done
  print -r -- "$BUFFER" > "$NG_HISTORY_TEST_ROOT/buffer"
  fc -W "$NG_HISTORY_TEST_ROOT/memory"
  print -r -- "found=$found
size=$HISTSIZE
save=$SAVEHIST
shared=$options[sharehistory]
done" > "$NG_HISTORY_TEST_ROOT/result"
}
zle -N ng-history-test-capture
bindkey -M viins '^X^T' ng-history-test-capture
bindkey -M vicmd '^X^T' ng-history-test-capture
EOF
    [[ "$failure" == yes ]] && print -r -- "HISTFILE=${(q)tmp}/missing/history" >> "$tmp/setup.zsh"

    zpty ng_history_test env TERM=xterm-256color zsh -f
    zpty -w ng_history_test " source ${(q)tmp}/setup.zsh"
    ng-history-test-wait "$tmp/ready" ready
    zpty -w -n ng_history_test "$keys"$'\x18\x0b'"$after_keys"$'\x18\x14'
    ng-history-test-wait "$tmp/result" done

    NG_HISTORY_TEST_STATE=()
    while IFS= read -r line; do
      [[ "$line" == *=* ]] && NG_HISTORY_TEST_STATE[${line%%=*}]="${line#*=}"
    done < "$tmp/result"
    NG_HISTORY_TEST_STATE[buffer]="$(<"$tmp/buffer")"
    NG_HISTORY_TEST_DISK="$(<"$tmp/history")"$'\n'
    NG_HISTORY_TEST_MEMORY="$(<"$tmp/memory")"$'\n'
    NG_HISTORY_TEST_BEFORE="$(<"$tmp/before")"$'\n'
  } always {
    zpty -d ng_history_test 2>/dev/null || true
    rm -rf -- "$tmp"
  }
}

ng-history-test-exact-removal() {
  local target keys mode entry serialized
  local -a entries
  for target in 'discard literal' 'discard [*]? literal' \
    $'discard multiline\nsecond line' 'discard '\''quoted'\'' "double" $HOME `pwd` \path'; do
    for mode in viins vicmd; do
      entries=( 'example before' "$target" "$target extra" "example $target" "$target" )
      keys=$'\e[A'
      [[ "$mode" == vicmd ]] && keys=$'\e'"$keys"
      ng-history-test-probe "$target" "$keys" '' no "${entries[@]}"
      ng-history-test-equals "${NG_HISTORY_TEST_STATE[found]}" 0
      serialized="${target//$'\n'/$'\\\n'}"
      ng-history-test-excludes "$NG_HISTORY_TEST_DISK" ";$serialized"$'\n'
      ng-history-test-excludes "$NG_HISTORY_TEST_MEMORY" ";$serialized"$'\n'
      for entry in 'example before' "$target extra" "example $target"; do
        serialized="${entry//$'\n'/$'\\\n'}"
        ng-history-test-contains "$NG_HISTORY_TEST_DISK" ";$serialized"$'\n'
        ng-history-test-contains "$NG_HISTORY_TEST_MEMORY" ";$serialized"$'\n'
      done
    done
  done
  ng-history-test-probe 'discard only' $'\e[A' '' no 'discard only'
  ng-history-test-equals "${NG_HISTORY_TEST_STATE[found]}" 0
  ng-history-test-excludes "$NG_HISTORY_TEST_DISK" 'discard only'
  ng-history-test-excludes "$NG_HISTORY_TEST_MEMORY" 'discard only'
}

ng-history-test-prompt-clearing() {
  ng-history-test-probe 'discard literal' $'discard\e[A' '' no 'example before' 'discard literal'
  ng-history-test-equals "${NG_HISTORY_TEST_STATE[buffer]}" ''
}

ng-history-test-navigation() {
  ng-history-test-probe 'discard literal' $'discard\e[A' $'\e[A' no 'example before' 'discard literal'
  ng-history-test-equals "${NG_HISTORY_TEST_STATE[buffer]}" 'example before'
  ng-history-test-equals "${NG_HISTORY_TEST_STATE[found]}" 0
}

ng-history-test-repeated-removal() {
  ng-history-test-probe 'discard literal' $'\e[A' $'\e[A\x18\x0b' no 'example before' 'discard literal'
  ng-history-test-equals "${NG_HISTORY_TEST_STATE[buffer]}" ''
  ng-history-test-excludes "$NG_HISTORY_TEST_DISK" 'example before'
  ng-history-test-excludes "$NG_HISTORY_TEST_MEMORY" 'example before'
  ng-history-test-excludes "$NG_HISTORY_TEST_DISK" 'discard literal'
  ng-history-test-excludes "$NG_HISTORY_TEST_MEMORY" 'discard literal'
}

ng-history-test-empty-buffer() {
  ng-history-test-probe absent '' '' no 'example before'
  ng-history-test-equals "${NG_HISTORY_TEST_STATE[buffer]}" ''
  ng-history-test-equals "$NG_HISTORY_TEST_DISK" "$NG_HISTORY_TEST_BEFORE"
}

ng-history-test-write-failure() {
  ng-history-test-probe 'discard literal' $'\e[A' '' yes 'example before' 'discard literal'
  ng-history-test-equals "${NG_HISTORY_TEST_STATE[buffer]}" 'discard literal'
  ng-history-test-equals "${NG_HISTORY_TEST_STATE[found]}" 1
  ng-history-test-equals "$NG_HISTORY_TEST_DISK" "$NG_HISTORY_TEST_BEFORE"
}

ng-history-test-settings-preserved() {
  ng-history-test-probe 'discard literal' $'\e[A' '' no 'example before' 'discard literal'
  ng-history-test-equals "${NG_HISTORY_TEST_STATE[size]}" 100000
  ng-history-test-equals "${NG_HISTORY_TEST_STATE[save]}" 100000
  ng-history-test-equals "${NG_HISTORY_TEST_STATE[shared]}" on
}

ng-history-test-timestamps-preserved() {
  ng-history-test-probe 'discard literal' $'\e[A' '' no 'example before' 'discard literal'
  ng-history-test-contains "$NG_HISTORY_TEST_DISK" ': 1700000000:1;example before'
}

ng-history-test-exact-removal
ng-history-test-prompt-clearing
ng-history-test-navigation
ng-history-test-repeated-removal
ng-history-test-empty-buffer
ng-history-test-write-failure
ng-history-test-settings-preserved
ng-history-test-timestamps-preserved
print -r -- 'history tests passed'
