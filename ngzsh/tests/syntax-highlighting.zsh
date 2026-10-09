#!/usr/bin/env zsh

emulate -L zsh
setopt err_return pipe_fail interactive_comments
zmodload zsh/zpty

typeset -r repo_ngzsh_dir="${0:A:h:h}"
typeset -r functions_dir="${repo_ngzsh_dir}/functions"

fpath=( "$functions_dir" $fpath )
autoload -Uz ng-syntax-highlight ng-syntax-highlight-spans ng-syntax-grammar-spans
typeset -gA NG_SYNTAX_HIGHLIGHT_STYLES

ng-fixture() { :; }

ng-syntax-test-expect-span() {
  local output="$1"
  local buffer="$2"
  local fragment="$3"
  local category="$4"
  local prefix expected line

  if [[ "$buffer" != *"$fragment"* ]]; then
    print -ru2 -- "fixture does not contain: $fragment"
    return 1
  fi

  prefix="${buffer%%"$fragment"*}"
  expected="${#prefix} $(( ${#prefix} + ${#fragment} )) $category"
  for line in ${(f)output}; do
    [[ "$line" = "$expected" ]] && return 0
  done

  print -ru2 -- "expected span: $expected"
  print -ru2 -- "actual spans:"
  print -ru2 -- "$output"
  return 1
}

ng-syntax-test-expect-no-category() {
  local output="$1"
  local category="$2"
  local line

  for line in ${(f)output}; do
    if [[ "$line" = *" $category" ]]; then
      print -ru2 -- "unexpected $category span: $line"
      print -ru2 -- "$output"
      return 1
    fi
  done
}

ng-syntax-test-expect-painted() {
  local output="$1"
  local buffer="$2"
  local fragment="$3"
  local style="$4"
  local category="$5"
  local prefix expected line

  if [[ "$buffer" != *"$fragment"* ]]; then
    print -ru2 -- "fixture does not contain: $fragment"
    return 1
  fi

  prefix="${buffer%%"$fragment"*}"
  expected="${#prefix} $(( ${#prefix} + ${#fragment} )) $style memo=ngzsh-syntax-highlighting:$category"
  for line in ${(f)output}; do
    [[ "$line" = "$expected" ]] && return 0
  done

  print -ru2 -- "expected highlight: $expected"
  print -ru2 -- "actual highlights:"
  print -ru2 -- "$output"
  return 1
}

ng-syntax-test-expect-no-owned-overlap() {
  local output="$1"
  integer protected_start="$2" protected_end="$3"
  local line rest
  integer start end

  for line in ${(f)output}; do
    [[ "$line" = *memo=ngzsh-syntax-highlighting:* ]] || continue
    start="${line%% *}"
    rest="${line#* }"
    end="${rest%% *}"
    if (( start < protected_end && end > protected_start )); then
      print -ru2 -- "syntax highlight overlaps protected range: $line"
      return 1
    fi
  done
}

ng-syntax-test-expect-contains() {
  if [[ "$1" != *"$2"* ]]; then
    print -ru2 -- "expected output to contain: $2"
    print -ru2 -- "actual output:"
    print -ru2 -- "$1"
    return 1
  fi
}

ng-syntax-test-expect-not-contains() {
  if [[ "$1" = *"$2"* ]]; then
    print -ru2 -- "unexpected output: $2"
    print -ru2 -- "$1"
    return 1
  fi
}

ng-syntax-test-read-pty-output() {
  local pty_name="$1"
  local chunk output

  while zpty -r -t "$pty_name" chunk; do
    output+="$chunk"
  done

  print -rn -- "$output"
}

ng-syntax-test-grammar-spans() {
  local buffer spans

  buffer='NG_FLAG=ng_value ng-fixture --mode "$NG_FLAG $(ng-nest)" >ng_sink # ng_note'
  spans="$(ng-syntax-grammar-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" 'NG_FLAG=ng_value' assignment
  ng-syntax-test-expect-span "$spans" "$buffer" 'ng-fixture' command-word
  ng-syntax-test-expect-span "$spans" "$buffer" '--mode' option
  ng-syntax-test-expect-span "$spans" "$buffer" '"$NG_FLAG $(ng-nest)"' string
  ng-syntax-test-expect-span "$spans" "$buffer" '$NG_FLAG' parameter-expansion
  ng-syntax-test-expect-span "$spans" "$buffer" '$(ng-nest)' command-substitution
  ng-syntax-test-expect-span "$spans" "$buffer" '>' redirection
  ng-syntax-test-expect-span "$spans" "$buffer" '# ng_note' comment

  buffer='ng_form() { print ng_value }; if true; then print =(ng_nest) *.ng; fi'
  spans="$(ng-syntax-grammar-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" 'ng_form' function
  ng-syntax-test-expect-span "$spans" "$buffer" 'if' reserved-word
  ng-syntax-test-expect-span "$spans" "$buffer" 'then' reserved-word
  ng-syntax-test-expect-span "$spans" "$buffer" 'fi' reserved-word
  ng-syntax-test-expect-span "$spans" "$buffer" '=(ng_nest)' process-substitution
  ng-syntax-test-expect-span "$spans" "$buffer" '*.ng' glob

  buffer='() { print ng_value }'
  spans="$(ng-syntax-grammar-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" '()' function

  buffer='ng-fixture --mount ng-volume:/ng/target --label "$NG_FLAG"'
  spans="$(ng-syntax-grammar-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" '--mount' option
  ng-syntax-test-expect-span "$spans" "$buffer" 'ng-volume:/ng/target' volume-spec
  ng-syntax-test-expect-span "$spans" "$buffer" '$NG_FLAG' parameter-expansion

  buffer='ng-fixture --left pre$(ng-nest -x)post --right n$((1+2)) --done ng_value'
  spans="$(ng-syntax-grammar-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" 'pre$(ng-nest -x)post' word
  ng-syntax-test-expect-span "$spans" "$buffer" '$(ng-nest -x)' command-substitution
  ng-syntax-test-expect-span "$spans" "$buffer" '--right' option
  ng-syntax-test-expect-span "$spans" "$buffer" 'n$((1+2))' word
  ng-syntax-test-expect-span "$spans" "$buffer" '$((1+2))' arithmetic-expansion
  ng-syntax-test-expect-span "$spans" "$buffer" '--done' option

  buffer='NG_FLAG=$(ng-nest) ng-fixture'
  spans="$(ng-syntax-grammar-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" 'NG_FLAG=$(ng-nest)' assignment
  ng-syntax-test-expect-span "$spans" "$buffer" 'ng-fixture' command-word
  ng-syntax-test-expect-no-category "$spans" separator

  buffer='ng-fixture "ng_unfinished'
  spans="$(ng-syntax-grammar-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" '"ng_unfinished' unclosed-string

  buffer='ng-fixture ng_value # ng_note'
  unsetopt interactive_comments
  spans="$(ng-syntax-grammar-spans "$buffer")"
  ng-syntax-test-expect-no-category "$spans" comment
  setopt interactive_comments
  spans="$(ng-syntax-grammar-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" '# ng_note' comment
}

ng-syntax-test-shell-command-lookup() {
  local tmp oldpath buffer spans

  tmp="$(mktemp -d)"
  print -r -- '#!/bin/sh' > "$tmp/ng-fake-exec"
  chmod +x -- "$tmp/ng-fake-exec"
  oldpath="$PATH"
  PATH="$tmp:$PATH"
  alias ng-fake-alias='print ng_value'

  buffer='ng-fake-alias; ng-fixture | ng-fake-exec && ng-no-such-command'
  spans="$(ng-syntax-highlight-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" 'ng-fake-alias' alias
  ng-syntax-test-expect-span "$spans" "$buffer" 'ng-fixture' function
  ng-syntax-test-expect-span "$spans" "$buffer" 'ng-fake-exec' command
  ng-syntax-test-expect-span "$spans" "$buffer" 'ng-no-such-command' unknown-command
  ng-syntax-test-expect-span "$spans" "$buffer" '|' separator
  ng-syntax-test-expect-span "$spans" "$buffer" '&&' separator

  buffer='print ng_value'
  spans="$(ng-syntax-highlight-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" 'print' builtin

  unalias ng-fake-alias
  PATH="$oldpath"
  rm -- "$tmp/ng-fake-exec"
  rmdir -- "$tmp"
}

ng-syntax-test-shell-paths() {
  local tmp oldpwd oldpath buffer spans
  local -a oldcdpath

  tmp="$(mktemp -d)"
  mkdir -p -- "$tmp/ng-dir" "$tmp/ng space" "$tmp/ngspace" "$tmp/ng;semi" "$tmp/ng-bin" "$tmp/ng-exec" "$tmp/ng-cdroot/ng-cdpath"
  touch -- "$tmp/ng-file"
  print -r -- '#!/bin/sh' > "$tmp/ng-bin/ng-exec"
  chmod +x -- "$tmp/ng-bin/ng-exec"
  oldpwd="$PWD"
  oldpath="$PATH"
  oldcdpath=( "$cdpath[@]" )
  cd -- "$tmp"
  PATH="$tmp/ng-bin:$PATH"
  cdpath=( "$tmp/ng-cdroot" )
  setopt AUTO_CD

  buffer='cd ng-dir'
  spans="$(ng-syntax-highlight-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" 'ng-dir' path-to-dir

  buffer='ng-dir'
  spans="$(ng-syntax-highlight-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" 'ng-dir' autodirectory

  buffer='ng-exec'
  spans="$(ng-syntax-highlight-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" 'ng-exec' command

  buffer='print ng-file'
  spans="$(ng-syntax-highlight-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" 'ng-file' path

  buffer='cd ng-cdpath'
  spans="$(ng-syntax-highlight-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" 'ng-cdpath' path-to-dir

  buffer='print ng-cdpath'
  spans="$(ng-syntax-highlight-spans "$buffer")"
  ng-syntax-test-expect-no-category "$spans" path-to-dir

  buffer='cd ng-d'
  spans="$(ng-syntax-highlight-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" 'ng-d' path-prefix

  buffer='cd ng-absent'
  spans="$(ng-syntax-highlight-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" 'ng-absent' missing-path

  buffer='ng-fixture >ng-absent'
  spans="$(ng-syntax-highlight-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" 'ng-absent' missing-path

  buffer='cd ./ng\ space'
  spans="$(ng-syntax-highlight-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" './ng\ space' path-to-dir

  buffer='cd ./ng\;semi'
  spans="$(ng-syntax-highlight-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" './ng\;semi' path-to-dir

  buffer=$'cd ./ng\\\nspace'
  spans="$(ng-syntax-highlight-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" $'\\\n' line-continuation
  ng-syntax-test-expect-span "$spans" "$buffer" $'./ng\\\nspace' path-to-dir

  buffer='cd ./ng-absent/$(ng-nest)'
  spans="$(ng-syntax-highlight-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" './ng-absent/$(ng-nest)' word
  ng-syntax-test-expect-span "$spans" "$buffer" '$(ng-nest)' command-substitution
  ng-syntax-test-expect-no-category "$spans" missing-path

  alias ng-fake-jump=ng-frequent-directories-jump
  buffer='ng-fake-jump ng-cdpath'
  spans="$(ng-syntax-highlight-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" 'ng-fake-jump' alias
  ng-syntax-test-expect-span "$spans" "$buffer" 'ng-cdpath' path-to-dir
  NG_DIRECTORY_CHANGING_COMMANDS=( cd chdir pushd )
  spans="$(ng-syntax-highlight-spans "$buffer")"
  ng-syntax-test-expect-no-category "$spans" path-to-dir
  NG_DIRECTORY_CHANGING_COMMANDS=( cd chdir pushd ng-frequent-directories-jump )
  unalias ng-fake-jump

  alias ng-dir=print
  buffer='ng-dir'
  spans="$(ng-syntax-highlight-spans "$buffer")"
  ng-syntax-test-expect-span "$spans" "$buffer" 'ng-dir' alias
  unalias ng-dir

  unsetopt AUTO_CD
  cdpath=( "$oldcdpath[@]" )
  PATH="$oldpath"
  cd -- "$oldpwd"
  rm -r -- "$tmp"
}

ng-syntax-test-paint-styles() {
  local buffer highlights

  buffer='ng-fixture --left pre$(ng-nest -x)post --right "ng_value"; ng-no-such-command'
  BUFFER="$buffer"
  region_highlight=()
  WIDGET=''
  LASTWIDGET=''
  ng-syntax-highlight
  highlights="${(F)region_highlight}"

  ng-syntax-test-expect-painted "$highlights" "$buffer" 'ng-fixture' fg=green function
  ng-syntax-test-expect-painted "$highlights" "$buffer" '--left' fg=cyan option
  ng-syntax-test-expect-painted "$highlights" "$buffer" '$(ng-nest -x)' none command-substitution
  ng-syntax-test-expect-painted "$highlights" "$buffer" '--right' fg=cyan option
  ng-syntax-test-expect-painted "$highlights" "$buffer" '"ng_value"' fg=yellow string
  ng-syntax-test-expect-painted "$highlights" "$buffer" 'ng-no-such-command' fg=red,bold unknown-command

  buffer='ng-fixture --mount ng-volume:/ng/target'
  BUFFER="$buffer"
  region_highlight=()
  ng-syntax-highlight
  highlights="${(F)region_highlight}"
  ng-syntax-test-expect-painted "$highlights" "$buffer" '--mount' fg=cyan option
  ng-syntax-test-expect-painted "$highlights" "$buffer" 'ng-volume:/ng/target' none volume-spec

  NG_SYNTAX_HIGHLIGHT_STYLES[function]=standout
  BUFFER='ng-fixture'
  region_highlight=()
  ng-syntax-highlight
  ng-syntax-test-expect-painted "${(F)region_highlight}" "$BUFFER" 'ng-fixture' standout function
  NG_SYNTAX_HIGHLIGHT_STYLES[function]=fg=green
}

ng-syntax-test-braced-parameter-case() {
  local buffer="$1" expansion="$2" following="$3" style="$4" category="$5" highlights

  BUFFER="$buffer"
  REGION_ACTIVE=0 WIDGET='' LASTWIDGET=''
  region_highlight=()
  ng-syntax-highlight
  highlights="${(F)region_highlight}"
  ng-syntax-test-expect-painted "$highlights" "$buffer" "$expansion" fg=cyan parameter-expansion
  ng-syntax-test-expect-painted "$highlights" "$buffer" "$following" "$style" "$category"
  ng-syntax-test-expect-parameter-count "$highlights" 1
}

ng-syntax-test-expect-parameter-count() {
  local output="$1" expected="$2" line
  integer actual=0

  for line in ${(f)output}; do
    [[ "$line" = *'memo=ngzsh-syntax-highlighting:parameter-expansion' ]] && (( ++actual ))
  done
  if (( actual != expected )); then
    print -ru2 -- "expected $expected parameter ranges, found $actual"
    print -ru2 -- "$output"
    return 1
  fi
}

ng-syntax-test-braced-parameters() {
  local buffer highlights expansion

  ng-syntax-test-braced-parameter-case 'print ${EXAMPLE} --example' '${EXAMPLE}' --example fg=cyan option
  ng-syntax-test-braced-parameter-case 'print pre${EXAMPLE}post --example' '${EXAMPLE}' --example fg=cyan option
  ng-syntax-test-braced-parameter-case 'EXAMPLE=${VALUE} print --example' '${VALUE}' print fg=green builtin
  ng-syntax-test-braced-parameter-case 'print "${EXAMPLE:-"}"}" --example' '${EXAMPLE:-"}"}' --example fg=cyan option
  ng-syntax-test-braced-parameter-case 'print ${EXAMPLE:-"}"} --example' '${EXAMPLE:-"}"}' --example fg=cyan option
  ng-syntax-test-braced-parameter-case 'print ${EXAMPLE:-{left,right}}; print --example' '${EXAMPLE:-{left,right}}' --example fg=cyan option
  ng-syntax-test-braced-parameter-case 'print ${EXAMPLE:-${NESTED}} --example' '${EXAMPLE:-${NESTED}}' --example fg=cyan option
  ng-syntax-test-braced-parameter-case 'print ${EXAMPLE:-$NESTED} --example' '${EXAMPLE:-$NESTED}' --example fg=cyan option

  buffer='print pre$OUT${EXAMPLE:-$INNER}post --example'
  BUFFER="$buffer"
  region_highlight=()
  ng-syntax-highlight
  highlights="${(F)region_highlight}"
  ng-syntax-test-expect-painted "$highlights" "$buffer" '$OUT' fg=cyan parameter-expansion
  ng-syntax-test-expect-painted "$highlights" "$buffer" '${EXAMPLE:-$INNER}' fg=cyan parameter-expansion
  ng-syntax-test-expect-painted "$highlights" "$buffer" '--example' fg=cyan option
  ng-syntax-test-expect-parameter-count "$highlights" 2

  for expansion in \
    '${EXAMPLE:-"}" --example' \
    '${EXAMPLE:-{left,right} --example' \
    '${EXAMPLE:-${NESTED} --example' \
    '${EXAMPLE:-"open --example'; do
    buffer="print $expansion"
    BUFFER="$buffer"
    region_highlight=()
    ng-syntax-highlight
    highlights="${(F)region_highlight}"
    ng-syntax-test-expect-painted "$highlights" "$buffer" "$expansion" fg=cyan parameter-expansion
    ng-syntax-test-expect-parameter-count "$highlights" 1
    ng-syntax-test-expect-not-contains "$highlights" 'memo=ngzsh-syntax-highlighting:option'
  done
}

ng-syntax-test-paint-region-ownership() {
  local buffer highlights

  buffer='ng-fixture --left "ng_value"; ng-fixture --right ng_value'
  BUFFER="$buffer"
  WIDGET=''
  LASTWIDGET=''
  region_highlight=( '0 1 fg=red memo=ngzsh-syntax-highlighting:old' '0 10 standout memo=zle-paste' )
  ng-syntax-highlight
  highlights="${(F)region_highlight}"
  ng-syntax-test-expect-contains "$highlights" '0 10 standout memo=zle-paste'
  ng-syntax-test-expect-not-contains "$highlights" 'ngzsh-syntax-highlighting:old'
  ng-syntax-test-expect-no-owned-overlap "$highlights" 0 10
  ng-syntax-test-expect-painted "$highlights" "$buffer" '--left' fg=cyan option

  region_highlight=()
  REGION_ACTIVE=1
  CURSOR=11
  MARK=17
  ng-syntax-highlight
  highlights="${(F)region_highlight}"
  ng-syntax-test-expect-no-owned-overlap "$highlights" 11 17
  ng-syntax-test-expect-painted "$highlights" "$buffer" 'ng-fixture' fg=green function
  REGION_ACTIVE=0

  region_highlight=()
  LASTWIDGET=bracketed-paste
  YANK_START=0
  YANK_END="${#buffer}"
  ng-syntax-highlight
  highlights="${(F)region_highlight}"
  ng-syntax-test-expect-no-owned-overlap "$highlights" 0 "${#buffer}"
  LASTWIDGET=''
  YANK_START=0
  YANK_END=0

  region_highlight=( '0 1 standout memo=zle-suffix' )
  NG_SYNTAX_HIGHLIGHT_MAX_BUFFER_LENGTH=4
  ng-syntax-highlight
  highlights="${(F)region_highlight}"
  ng-syntax-test-expect-contains "$highlights" '0 1 standout memo=zle-suffix'
  ng-syntax-test-expect-no-owned-overlap "$highlights" 0 "${#buffer}"
  NG_SYNTAX_HIGHLIGHT_MAX_BUFFER_LENGTH=20000
}

ng-syntax-test-interactive-paste() {
  local output
  local paste_text='ng-fiction --left "ng_value"'
  local paste_standout=$'\e[7m'"$paste_text"$'\e[27m'

  zpty ng_syntax_paste_probe zsh -f
  zpty -w ng_syntax_paste_probe $'export TERM=xterm-256color\n'
  zpty -w ng_syntax_paste_probe $'PS1="PROMPT> "\n'
  zpty -w ng_syntax_paste_probe "fpath=($functions_dir \$fpath)"$'\n'
  zpty -w ng_syntax_paste_probe $'autoload -Uz ng-syntax-highlight ng-syntax-highlight-spans\n'
  zpty -w ng_syntax_paste_probe $'typeset -gA NG_SYNTAX_HIGHLIGHT_STYLES\n'
  zpty -w ng_syntax_paste_probe "source $repo_ngzsh_dir/interactive/syntax-highlighting.zsh"$'\n'
  zpty -w ng_syntax_paste_probe $'zle_highlight=(paste:standout)\n'

  sleep 0.4
  ng-syntax-test-read-pty-output ng_syntax_paste_probe >/dev/null

  zpty -w -n ng_syntax_paste_probe $'\e[200~'"$paste_text"$'\e[201~'
  sleep 0.5
  output="$(ng-syntax-test-read-pty-output ng_syntax_paste_probe)"

  zpty -d ng_syntax_paste_probe

  ng-syntax-test-expect-contains "$output" "$paste_standout"
  ng-syntax-test-expect-not-contains "$output" $'\e[31m'
}

ng-syntax-test-interactive-autodirectory() {
  local tmp output
  local autodirectory_style=$'\e[4m\e[35m.\e[4m\e[35m.\e[24m\e[39m'

  tmp="$(mktemp -d)"
  mkdir -p -- "$tmp/ng-parent/ng-child"

  zpty ng_syntax_autocd_probe zsh -f
  zpty -w ng_syntax_autocd_probe $'export TERM=xterm-256color\n'
  zpty -w ng_syntax_autocd_probe $'PS1="PROMPT> "\n'
  zpty -w ng_syntax_autocd_probe "fpath=($functions_dir \$fpath)"$'\n'
  zpty -w ng_syntax_autocd_probe $'autoload -Uz ng-syntax-highlight ng-syntax-highlight-spans\n'
  zpty -w ng_syntax_autocd_probe "cd ${(q)tmp}/ng-parent/ng-child"$'\n'
  zpty -w ng_syntax_autocd_probe $'setopt AUTO_CD\n'
  zpty -w ng_syntax_autocd_probe "source $repo_ngzsh_dir/interactive/syntax-highlighting.zsh"$'\n'

  sleep 0.4
  ng-syntax-test-read-pty-output ng_syntax_autocd_probe >/dev/null

  zpty -w -n ng_syntax_autocd_probe '..'
  sleep 0.5
  output="$(ng-syntax-test-read-pty-output ng_syntax_autocd_probe)"

  zpty -d ng_syntax_autocd_probe
  rm -r -- "$tmp"

  ng-syntax-test-expect-contains "$output" "$autodirectory_style"
}

ng-syntax-test-grammar-spans
ng-syntax-test-shell-command-lookup
ng-syntax-test-shell-paths
ng-syntax-test-paint-styles
ng-syntax-test-braced-parameters
ng-syntax-test-paint-region-ownership
ng-syntax-test-interactive-paste
ng-syntax-test-interactive-autodirectory

print -r -- "syntax highlighting tests passed"
