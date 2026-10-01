#!/usr/bin/env zsh

emulate -L zsh
setopt err_return pipe_fail interactive_comments
zmodload zsh/zpty

typeset -r repo_ngzsh_dir="${0:A:h:h}"
typeset -r functions_dir="${repo_ngzsh_dir}/functions"

fpath=( "$functions_dir" $fpath )
autoload -Uz ng-directory-changing-command ng-directory-resolve ng-syntax-highlight ng-syntax-highlight-spans ng-syntax-grammar-spans ng-syntax-shell-spans
typeset -gA NG_SYNTAX_HIGHLIGHT_STYLES

ng-syntax-test-assert-contains() {
  local haystack="$1"
  local needle="$2"

  if [[ "$haystack" != *"$needle"* ]]; then
    print -ru2 -- "expected output to contain: $needle"
    print -ru2 -- "actual output:"
    print -ru2 -- "$haystack"
    return 1
  fi
}

ng-syntax-test-assert-not-contains() {
  local haystack="$1"
  local needle="$2"

  if [[ "$haystack" == *"$needle"* ]]; then
    print -ru2 -- "expected output not to contain: $needle"
    print -ru2 -- "actual output:"
    print -ru2 -- "$haystack"
    return 1
  fi
}

ng-syntax-test-spans-for() {
  ng-syntax-highlight-spans "$1"
}

ng-syntax-test-grammar-spans-for() {
  ng-syntax-grammar-spans "$1"
}

ng-syntax-test-read-pty-output() {
  local pty_name="$1"
  local chunk output

  while zpty -r -t "$pty_name" chunk; do
    output+="$chunk"
  done

  print -rn -- "$output"
}

ng-syntax-test-command-classification() {
  local output

  alias ngx_alias='print alias'
  ng-syntax-test-qzvxabc-function() { :; }

  output="$(ng-syntax-test-spans-for 'ngx_alias; ng-syntax-test-qzvxabc-function | whence && sh && definitely-not-a-command')"

  ng-syntax-test-assert-contains "$output" "0 9 alias"
  ng-syntax-test-assert-contains "$output" "9 10 separator"
  ng-syntax-test-assert-contains "$output" "11 42 function"
  ng-syntax-test-assert-contains "$output" "43 44 separator"
  ng-syntax-test-assert-contains "$output" "45 51 builtin"
  ng-syntax-test-assert-contains "$output" "52 54 separator"
  ng-syntax-test-assert-contains "$output" "55 57 command"
  ng-syntax-test-assert-contains "$output" "58 60 separator"
  ng-syntax-test-assert-contains "$output" "61 85 unknown-command"
}

ng-syntax-test-assignments-redirects-strings-comments-and-substitutions() {
  local output

  output="$(ng-syntax-test-spans-for 'FOO=bar print "$FOO $(date)" >out # comment')"

  ng-syntax-test-assert-contains "$output" "0 7 assignment"
  ng-syntax-test-assert-contains "$output" "8 13 builtin"
  ng-syntax-test-assert-contains "$output" "14 28 string"
  ng-syntax-test-assert-contains "$output" "15 19 parameter-expansion"
  ng-syntax-test-assert-contains "$output" "20 27 command-substitution"
  ng-syntax-test-assert-contains "$output" "29 30 redirection"
  ng-syntax-test-assert-contains "$output" "30 33 missing-path"
  ng-syntax-test-assert-contains "$output" "34 43 comment"
}

ng-syntax-test-paths-globs-and-incomplete-quotes() {
  local tmp oldpwd output

  tmp="$(mktemp -d)"
  mkdir -p -- "$tmp/qzvx-syntax-src"
  touch -- "$tmp/qzvx-syntax-src/qzvx-alpha"

  oldpwd="$PWD"
  cd -- "$tmp"

  output="$(ng-syntax-test-spans-for "print ${tmp}/qzvx-syntax-src ${tmp}/qzvx-syntax-src/qzvx-al ${tmp}/qzvx-missing *.zsh qzvx-al 'open")"

  ng-syntax-test-assert-contains "$output" "path"
  ng-syntax-test-assert-contains "$output" "path-prefix"
  ng-syntax-test-assert-contains "$output" "missing-path"
  ng-syntax-test-assert-contains "$output" "glob"
  ng-syntax-test-assert-contains "$output" "unclosed-string"

  cd -- "$oldpwd"
  rm -rf -- "$tmp"
}

ng-syntax-test-escaped-paths() {
  local tmp oldpwd output buffer operand

  tmp="$(mktemp -d)"
  mkdir -p -- "$tmp/qzvxaa qzvxbb" "$tmp/qzvxaa;qzvxbb" "$tmp/qzvxaa\"qzvxbb" "$tmp/qzvxaa\\qzvxbb"
  touch -- "$tmp/qzvxbb file"
  oldpwd="$PWD"
  cd -- "$tmp"

  for operand in './qzvxaa\ qzvxbb' './qzvxaa\;qzvxbb' './qzvxaa\"qzvxbb' './qzvxaa\\qzvxbb'; do
    buffer="cd $operand"
    output="$(ng-syntax-test-grammar-spans-for "$buffer")"
    ng-syntax-test-assert-contains "$output" "3 ${#buffer} path-word"
    output="$(ng-syntax-test-spans-for "$buffer")"
    ng-syntax-test-assert-contains "$output" "3 ${#buffer} path-to-dir"
    ng-syntax-test-assert-not-contains "$output" "missing-path"
  done

  buffer="cd ${tmp}/qzvxaa\\ qzvxbb"
  output="$(ng-syntax-test-spans-for "$buffer")"
  ng-syntax-test-assert-contains "$output" "3 ${#buffer} path-to-dir"

  output="$(ng-syntax-test-spans-for 'cd ./qzvxaa\ qz')"
  ng-syntax-test-assert-contains "$output" "3 15 path-prefix"
  output="$(ng-syntax-test-spans-for 'cd ./qzvxzzz\ qzvxbb')"
  ng-syntax-test-assert-contains "$output" "3 20 missing-path"
  output="$(ng-syntax-test-spans-for 'print ./qzvxbb\ file')"
  ng-syntax-test-assert-contains "$output" "6 20 path"
  output="$(ng-syntax-test-spans-for 'cd ./qzvxaa qzvxbb')"
  ng-syntax-test-assert-contains "$output" "3 11 path-prefix"
  ng-syntax-test-assert-not-contains "$output" "3 18 path-to-dir"

  BUFFER='cd ./qzvxaa\ qzvxbb; print ok'
  region_highlight=()
  WIDGET=''
  LASTWIDGET=''
  ng-syntax-highlight
  output="${region_highlight[*]}"
  ng-syntax-test-assert-contains "$output" "3 19 fg=magenta,underline memo=ngzsh-syntax-highlighting:path-to-dir"
  ng-syntax-test-assert-contains "$output" "19 20 none memo=ngzsh-syntax-highlighting:separator"
  ng-syntax-test-assert-contains "$output" "21 26 fg=green memo=ngzsh-syntax-highlighting:builtin"

  cd -- "$oldpwd"
  rm -rf -- "$tmp"
}

ng-syntax-test-line-continuations() {
  local tmp oldpwd output buffer

  tmp="$(mktemp -d)"
  mkdir -p -- "$tmp/qzvxaaqzvxbb" "$tmp/qzvxaa qzvxbb"
  oldpwd="$PWD"
  cd -- "$tmp"

  buffer=$'cd ./qzvxaa\\\nqzvxbb'
  output="$(ng-syntax-test-grammar-spans-for "$buffer")"
  ng-syntax-test-assert-contains "$output" "11 13 line-continuation"
  ng-syntax-test-assert-contains "$output" "3 ${#buffer} path-word"
  output="$(ng-syntax-test-spans-for "$buffer")"
  ng-syntax-test-assert-contains "$output" "3 ${#buffer} path-to-dir"

  buffer=$'cd \\\n./qzvxaa\\ qzvxbb'
  output="$(ng-syntax-test-spans-for "$buffer")"
  ng-syntax-test-assert-contains "$output" "3 5 line-continuation"
  ng-syntax-test-assert-contains "$output" "5 ${#buffer} path-to-dir"
  ng-syntax-test-assert-not-contains "$output" "missing-path"

  output="$(ng-syntax-test-grammar-spans-for $'cd ./qzvxaa\\\\\nqzvxbb')"
  ng-syntax-test-assert-not-contains "$output" "line-continuation"
  ng-syntax-test-assert-contains "$output" "3 13 path-word"
  ng-syntax-test-assert-contains "$output" "14 20 word"

  buffer=$'cd ./qzvxaa\\'
  output="$(ng-syntax-test-grammar-spans-for "$buffer")"
  ng-syntax-test-assert-contains "$output" "3 ${#buffer} path-word"
  ng-syntax-test-assert-not-contains "$output" "line-continuation"

  cd -- "$oldpwd"
  rm -rf -- "$tmp"
}

ng-syntax-test-grammar_layer_does_not_do_live_shell_semantics() {
  local tmp oldpwd output

  tmp="$(mktemp -d)"
  mkdir -p -- "$tmp/qzvx-child"
  oldpwd="$PWD"
  cd -- "$tmp/qzvx-child"
  alias ngx_grammar_alias='print alias'
  setopt AUTO_CD

  output="$(ng-syntax-test-grammar-spans-for 'ngx_grammar_alias; cd ..; ..')"

  ng-syntax-test-assert-contains "$output" "0 17 command-word"
  ng-syntax-test-assert-not-contains "$output" "0 17 alias"
  ng-syntax-test-assert-contains "$output" "19 21 command-word"
  ng-syntax-test-assert-not-contains "$output" "19 21 builtin"
  ng-syntax-test-assert-contains "$output" "22 24 path-word"
  ng-syntax-test-assert-not-contains "$output" "22 24 path-to-dir"
  ng-syntax-test-assert-contains "$output" "26 28 command-word"
  ng-syntax-test-assert-not-contains "$output" "26 28 autodirectory"

  unalias ngx_grammar_alias
  unsetopt AUTO_CD
  cd -- "$oldpwd"
  rm -rf -- "$tmp"
}

ng-syntax-test-directory_semantics_and_autocd() {
  local tmp oldpwd output

  tmp="$(mktemp -d)"
  mkdir -p -- "$tmp/qzvx-parent/qzvx-child"
  oldpwd="$PWD"
  cd -- "$tmp/qzvx-parent/qzvx-child"

  setopt AUTO_CD
  output="$(ng-syntax-test-spans-for 'cd ..; ..')"
  ng-syntax-test-assert-contains "$output" "0 2 builtin"
  ng-syntax-test-assert-contains "$output" "3 5 path-to-dir"
  ng-syntax-test-assert-contains "$output" "7 9 autodirectory"
  ng-syntax-test-assert-not-contains "$output" "7 9 unknown-command"

  unsetopt AUTO_CD
  output="$(ng-syntax-test-spans-for '..')"
  ng-syntax-test-assert-contains "$output" "0 2 unknown-command"
  ng-syntax-test-assert-not-contains "$output" "0 2 autodirectory"

  cd -- "$oldpwd"
  rm -rf -- "$tmp"
}

ng-syntax-test_autocd_precedence_prefers_executable_commands_and_aliases() {
  local tmp oldpwd oldpath output

  tmp="$(mktemp -d)"
  mkdir -p -- "$tmp/qzvx-bin" "$tmp/qzvx-cdpath-root/qzvxcmd" "$tmp/qzvx-cwd/qzvx_alias_target"
  print -r -- '#!/bin/sh' > "$tmp/qzvx-bin/qzvxcmd"
  chmod +x -- "$tmp/qzvx-bin/qzvxcmd"
  oldpwd="$PWD"
  oldpath="$PATH"
  cd -- "$tmp/qzvx-cwd"
  PATH="${tmp}/qzvx-bin:${PATH}"
  cdpath=( "$tmp/qzvx-cdpath-root" )
  setopt AUTO_CD

  output="$(ng-syntax-test-spans-for 'qzvxcmd')"
  ng-syntax-test-assert-contains "$output" "0 7 command"
  ng-syntax-test-assert-not-contains "$output" "0 7 autodirectory"

  alias qzvx_alias_target='print alias'
  output="$(ng-syntax-test-spans-for 'qzvx_alias_target')"
  ng-syntax-test-assert-contains "$output" "0 17 alias"
  ng-syntax-test-assert-not-contains "$output" "0 17 autodirectory"
  unalias qzvx_alias_target

  PATH="$oldpath"
  unsetopt AUTO_CD
  cd -- "$oldpwd"
  rm -rf -- "$tmp"
}

ng-syntax-test_cdpath_is_limited_to_directory_changing_semantics() {
  local tmp oldpwd output

  tmp="$(mktemp -d)"
  mkdir -p -- "$tmp/qzvx-cdpath-root/qzvx-cdpath-dir" "$tmp/qzvx-cwd"
  oldpwd="$PWD"
  cd -- "$tmp/qzvx-cwd"
  cdpath=( "$tmp/qzvx-cdpath-root" )

  output="$(ng-syntax-test-spans-for 'cd qzvx-cdpath-dir; echo qzvx-cdpath-dir')"
  ng-syntax-test-assert-contains "$output" "0 2 builtin"
  ng-syntax-test-assert-contains "$output" "3 18 path-to-dir"
  ng-syntax-test-assert-contains "$output" "20 24 builtin"
  ng-syntax-test-assert-not-contains "$output" "25 40 path-to-dir"
  ng-syntax-test-assert-not-contains "$output" "25 40 path-prefix"

  output="$(ng-syntax-test-spans-for 'echo qzvx-cdpath-dir/')"
  ng-syntax-test-assert-contains "$output" "0 4 builtin"
  ng-syntax-test-assert-contains "$output" "5 21 missing-path"
  ng-syntax-test-assert-not-contains "$output" "5 21 path-to-dir"

  output="$(ng-syntax-test-spans-for 'cd qzvx-cdpath-dir/')"
  ng-syntax-test-assert-contains "$output" "0 2 builtin"
  ng-syntax-test-assert-contains "$output" "3 19 path-to-dir"
  ng-syntax-test-assert-not-contains "$output" "3 19 missing-path"

  setopt AUTO_CD
  output="$(ng-syntax-test-spans-for 'qzvx-cdpath-dir')"
  ng-syntax-test-assert-contains "$output" "0 15 autodirectory"

  output="$(ng-syntax-test-spans-for 'qzvx-cdpath-dir/')"
  ng-syntax-test-assert-contains "$output" "0 16 autodirectory"
  ng-syntax-test-assert-not-contains "$output" "0 16 unknown-command"

  unsetopt AUTO_CD
  cd -- "$oldpwd"
  rm -rf -- "$tmp"
}

ng-syntax-test_configurable_directory_changing_commands_resolve_simple_aliases() {
  local tmp oldpwd output

  tmp="$(mktemp -d)"
  mkdir -p -- "$tmp/qzvx-cdpath-root/qzvx-cdpath-dir" "$tmp/qzvx-cwd"
  oldpwd="$PWD"
  cd -- "$tmp/qzvx-cwd"
  cdpath=( "$tmp/qzvx-cdpath-root" )
  alias j=ng-frequent-directories-jump

  output="$(ng-syntax-test-spans-for 'j qzvx-cdpath-dir')"
  ng-syntax-test-assert-contains "$output" "0 1 alias"
  ng-syntax-test-assert-contains "$output" "2 17 path-to-dir"

  NG_DIRECTORY_CHANGING_COMMANDS=( cd chdir pushd )
  output="$(ng-syntax-test-spans-for 'j qzvx-cdpath-dir')"
  ng-syntax-test-assert-contains "$output" "0 1 alias"
  ng-syntax-test-assert-not-contains "$output" "2 17 path-to-dir"

  NG_DIRECTORY_CHANGING_COMMANDS=( cd chdir pushd ng-frequent-directories-jump )
  unalias j
  cd -- "$oldpwd"
  rm -rf -- "$tmp"
}

ng-syntax-test-function-definitions-process-substitutions-and-fd-redirects() {
  local output

  output="$(ng-syntax-test-spans-for 'foo() { print hi }; function bar; print =(date) 2>out')"

  ng-syntax-test-assert-contains "$output" "0 3 function"
  ng-syntax-test-assert-contains "$output" "20 28 reserved-word"
  ng-syntax-test-assert-contains "$output" "29 32 function"
  ng-syntax-test-assert-contains "$output" "40 47 process-substitution"
  ng-syntax-test-assert-contains "$output" "48 50 redirection"
  ng-syntax-test-assert-contains "$output" "50 53 missing-path"
}

ng-syntax-test-anonymous-functions-and-control-flow-command-position() {
  local output

  output="$(ng-syntax-test-spans-for '() { print hi }; if true; then print hi; fi')"

  ng-syntax-test-assert-contains "$output" "0 2 function"
  ng-syntax-test-assert-contains "$output" "5 10 builtin"
  ng-syntax-test-assert-contains "$output" "17 19 reserved-word"
  ng-syntax-test-assert-contains "$output" "20 24 builtin"
  ng-syntax-test-assert-contains "$output" "26 30 reserved-word"
  ng-syntax-test-assert-contains "$output" "31 36 builtin"
  ng-syntax-test-assert-contains "$output" "41 43 reserved-word"
}

ng-syntax-test-options-volume_specs-and-parameter-expansions() {
  local output

  output="$(ng-syntax-test-spans-for 'docker run --rm -it -v qzvx-volume:/qzvx/container -v "$PWD:/qzvx/mountpoint" qzvx-image:latest')"

  ng-syntax-test-assert-contains "$output" "11 15 option"
  ng-syntax-test-assert-contains "$output" "16 19 option"
  ng-syntax-test-assert-contains "$output" "20 22 option"
  ng-syntax-test-assert-contains "$output" "23 50 volume-spec"
  ng-syntax-test-assert-not-contains "$output" "23 50 missing-path"
  ng-syntax-test-assert-contains "$output" "55 59 parameter-expansion"
}

ng-syntax-test-default-rendering-for-commands-options-and-volume-specs() {
  local output

  BUFFER='sh run --rm -it -v qzvx-volume:/qzvx/container -v "$PWD:/qzvx/mountpoint" qzvx-image:latest'
  region_highlight=()
  WIDGET=''
  LASTWIDGET=''

  ng-syntax-highlight
  output="${region_highlight[*]}"

  ng-syntax-test-assert-contains "$output" "0 2 fg=green memo=ngzsh-syntax-highlighting:command"
  ng-syntax-test-assert-contains "$output" "7 11 fg=cyan memo=ngzsh-syntax-highlighting:option"
  ng-syntax-test-assert-contains "$output" "12 15 fg=cyan memo=ngzsh-syntax-highlighting:option"
  ng-syntax-test-assert-contains "$output" "16 18 fg=cyan memo=ngzsh-syntax-highlighting:option"
  ng-syntax-test-assert-contains "$output" "19 46 none memo=ngzsh-syntax-highlighting:volume-spec"
  ng-syntax-test-assert-not-contains "$output" "19 46 fg=red,bold"
}

ng-syntax-test-default-rendering-for-paths-globs-redirections-and-directories() {
  local tmp oldpwd output

  tmp="$(mktemp -d)"
  mkdir -p -- "$tmp/qzvx-parent/qzvx-child"
  mkdir -p -- "$tmp/qzvx-parent/qzvx-child/qzvx-dir"
  touch -- "$tmp/qzvx-parent/qzvx-child/qzvx-dir/qzvx-file"
  oldpwd="$PWD"
  cd -- "$tmp/qzvx-parent/qzvx-child"
  setopt AUTO_CD

  BUFFER='print qzvx-dir/qzvx-file qzvx-dir/qzvx-fi *.zsh >qzvx-out; cd ..; ..'
  region_highlight=()
  WIDGET=''
  LASTWIDGET=''

  ng-syntax-highlight
  output="${region_highlight[*]}"

  ng-syntax-test-assert-contains "$output" "6 24 fg=magenta memo=ngzsh-syntax-highlighting:path"
  ng-syntax-test-assert-contains "$output" "25 41 none memo=ngzsh-syntax-highlighting:path-prefix"
  ng-syntax-test-assert-contains "$output" "42 47 fg=blue,bold memo=ngzsh-syntax-highlighting:glob"
  ng-syntax-test-assert-contains "$output" "48 49 none memo=ngzsh-syntax-highlighting:redirection"
  ng-syntax-test-assert-contains "$output" "62 64 fg=magenta,underline memo=ngzsh-syntax-highlighting:path-to-dir"
  ng-syntax-test-assert-contains "$output" "66 68 fg=magenta,underline memo=ngzsh-syntax-highlighting:autodirectory"
  ng-syntax-test-assert-not-contains "$output" "66 68 fg=red,bold"

  unsetopt AUTO_CD
  cd -- "$oldpwd"
  rm -rf -- "$tmp"
}

ng-syntax-test-paint-preserves-foreign-regions-and-removes-old-ng-regions() {
  local original_widget="${WIDGET-}"
  local original_lastwidget="${LASTWIDGET-}"

  BUFFER='print nope'
  region_highlight=( '1 2 fg=red memo=ngzsh-syntax-highlighting:old' )
  NG_SYNTAX_HIGHLIGHT_STYLES[builtin]=standout
  WIDGET=''
  LASTWIDGET=''

  ng-syntax-highlight

  ng-syntax-test-assert-not-contains "${region_highlight[*]}" "old"
  ng-syntax-test-assert-contains "${region_highlight[*]}" "standout memo=ngzsh-syntax-highlighting:builtin"

  WIDGET="$original_widget"
  LASTWIDGET="$original_lastwidget"
}

ng-syntax-test-paint-preserves-foreign-regions-without-layering-syntax() {
  BUFFER='echo "alio"'
  region_highlight=( '0 11 standout memo=zle-paste' '1 2 fg=red memo=ngzsh-syntax-highlighting:old' )
  WIDGET=''

  ng-syntax-highlight

  ng-syntax-test-assert-contains "${region_highlight[*]}" "0 11 standout memo=zle-paste"
  ng-syntax-test-assert-not-contains "${region_highlight[*]}" "ngzsh-syntax-highlighting"
}

ng-syntax-test-paint-highlights-outside-foreign-regions() {
  BUFFER='echo "aaa"; echo "bbb"'
  region_highlight=( '12 22 standout memo=zle-suffix' )
  WIDGET=''
  LASTWIDGET=''
  NG_SYNTAX_HIGHLIGHT_STYLES[builtin]=standout
  NG_SYNTAX_HIGHLIGHT_STYLES[string]=underline

  ng-syntax-highlight

  ng-syntax-test-assert-contains "${region_highlight[*]}" "0 4 standout memo=ngzsh-syntax-highlighting:builtin"
  ng-syntax-test-assert-contains "${region_highlight[*]}" "5 10 underline memo=ngzsh-syntax-highlighting:string"
  ng-syntax-test-assert-contains "${region_highlight[*]}" "12 22 standout memo=zle-suffix"
  ng-syntax-test-assert-not-contains "${region_highlight[*]}" "12 16"
  ng-syntax-test-assert-not-contains "${region_highlight[*]}" "17 22"
}

ng-syntax-test-paint-skips-bracketed-paste-regions() {
  local original_widget="${WIDGET-}"
  local original_lastwidget="${LASTWIDGET-}"
  local original_yank_start="${YANK_START-0}"
  local original_yank_end="${YANK_END-0}"

  BUFFER='definitely-not-a-command pasted words'
  region_highlight=( '0 35 standout memo=zle-paste' )
  WIDGET=zle-line-pre-redraw
  LASTWIDGET=bracketed-paste
  YANK_START=0
  YANK_END=35

  ng-syntax-highlight

  ng-syntax-test-assert-contains "${region_highlight[*]}" "0 35 standout memo=zle-paste"
  ng-syntax-test-assert-not-contains "${region_highlight[*]}" "ngzsh-syntax-highlighting"

  WIDGET="$original_widget"
  LASTWIDGET="$original_lastwidget"
  YANK_START="$original_yank_start"
  YANK_END="$original_yank_end"
}

ng-syntax-test-paint-highlights-outside-bracketed-paste-range() {
  local original_widget="${WIDGET-}"
  local original_lastwidget="${LASTWIDGET-}"
  local original_yank_start="${YANK_START-0}"
  local original_yank_end="${YANK_END-0}"

  BUFFER='echo "aaa"; echo "aaa"'
  region_highlight=()
  WIDGET=zle-line-pre-redraw
  LASTWIDGET=bracketed-paste
  YANK_START=11
  YANK_END=22
  NG_SYNTAX_HIGHLIGHT_STYLES[builtin]=standout
  NG_SYNTAX_HIGHLIGHT_STYLES[string]=underline

  ng-syntax-highlight

  ng-syntax-test-assert-contains "${region_highlight[*]}" "0 4 standout memo=ngzsh-syntax-highlighting:builtin"
  ng-syntax-test-assert-contains "${region_highlight[*]}" "5 10 underline memo=ngzsh-syntax-highlighting:string"
  ng-syntax-test-assert-not-contains "${region_highlight[*]}" "11 15"
  ng-syntax-test-assert-not-contains "${region_highlight[*]}" "16 21"

  WIDGET="$original_widget"
  LASTWIDGET="$original_lastwidget"
  YANK_START="$original_yank_start"
  YANK_END="$original_yank_end"
}

ng-syntax-test-paint-skips-active-visual-selection() {
  local original_region_active="${REGION_ACTIVE-0}"

  BUFFER='definitely-not-a-command selected words'
  region_highlight=( '0 37 standout' )
  WIDGET=''
  REGION_ACTIVE=1

  ng-syntax-highlight

  ng-syntax-test-assert-contains "${region_highlight[*]}" "0 37 standout"
  ng-syntax-test-assert-not-contains "${region_highlight[*]}" "ngzsh-syntax-highlighting"

  REGION_ACTIVE="$original_region_active"
}

ng-syntax-test-bracketed-paste-pty-keeps-whole-paste-highlighted() {
  local output
  local paste_standout=$'\e[7mecho "alio"\e[27m'

  zpty ng_syntax_paste_probe zsh -f
  zpty -w ng_syntax_paste_probe $'export TERM=xterm-256color\n'
  zpty -w ng_syntax_paste_probe $'PS1="PROMPT> "\n'
  zpty -w ng_syntax_paste_probe "fpath=(${functions_dir} \$fpath)"$'\n'
  zpty -w ng_syntax_paste_probe $'autoload -Uz ng-syntax-highlight ng-syntax-highlight-spans\n'
  zpty -w ng_syntax_paste_probe $'typeset -gA NG_SYNTAX_HIGHLIGHT_STYLES\n'
  zpty -w ng_syntax_paste_probe $'NG_SYNTAX_HIGHLIGHT_STYLES=(builtin fg=red string fg=blue unknown-command fg=green)\n'
  zpty -w ng_syntax_paste_probe "source ${repo_ngzsh_dir}/interactive/syntax-highlighting.zsh"$'\n'
  zpty -w ng_syntax_paste_probe $'zle_highlight=(paste:standout)\n'

  sleep 0.4
  ng-syntax-test-read-pty-output ng_syntax_paste_probe >/dev/null

  zpty -w -n ng_syntax_paste_probe $'\e[200~echo "alio"\e[201~'
  sleep 0.5
  output="$(ng-syntax-test-read-pty-output ng_syntax_paste_probe)"

  zpty -d ng_syntax_paste_probe

  ng-syntax-test-assert-contains "$output" "$paste_standout"
  ng-syntax-test-assert-not-contains "$output" $'\e[31m'
  ng-syntax-test-assert-not-contains "$output" $'\e[34m'
}

ng-syntax-test-pty-renders-autodirectory-with-directory-style() {
  local tmp output
  local autodirectory_style=$'\e[4m\e[35m.\e[4m\e[35m.\e[24m\e[39m'

  tmp="$(mktemp -d)"
  mkdir -p -- "$tmp/qzvx-parent/qzvx-child"

  zpty ng_syntax_autocd_probe zsh -f
  zpty -w ng_syntax_autocd_probe $'export TERM=xterm-256color\n'
  zpty -w ng_syntax_autocd_probe $'PS1="PROMPT> "\n'
  zpty -w ng_syntax_autocd_probe "fpath=(${functions_dir} \$fpath)"$'\n'
  zpty -w ng_syntax_autocd_probe $'autoload -Uz ng-syntax-highlight ng-syntax-highlight-spans ng-syntax-grammar-spans ng-syntax-shell-spans\n'
  zpty -w ng_syntax_autocd_probe $'typeset -gA NG_SYNTAX_HIGHLIGHT_STYLES\n'
  zpty -w ng_syntax_autocd_probe "cd ${(q)tmp}/qzvx-parent/qzvx-child"$'\n'
  zpty -w ng_syntax_autocd_probe $'setopt AUTO_CD\n'
  zpty -w ng_syntax_autocd_probe "source ${repo_ngzsh_dir}/interactive/syntax-highlighting.zsh"$'\n'

  sleep 0.4
  ng-syntax-test-read-pty-output ng_syntax_autocd_probe >/dev/null

  zpty -w -n ng_syntax_autocd_probe '..'
  sleep 0.5
  output="$(ng-syntax-test-read-pty-output ng_syntax_autocd_probe)"

  zpty -d ng_syntax_autocd_probe
  rm -rf -- "$tmp"

  ng-syntax-test-assert-contains "$output" "$autodirectory_style"
}

ng-syntax-test-large-buffers-are-skipped() {
  local output

  NG_SYNTAX_HIGHLIGHT_MAX_BUFFER_LENGTH=4 output="$(ng-syntax-test-spans-for 'print')"

  [[ -z "$output" ]]
}

ng-syntax-test-command-classification
ng-syntax-test-assignments-redirects-strings-comments-and-substitutions
ng-syntax-test-paths-globs-and-incomplete-quotes
ng-syntax-test-escaped-paths
ng-syntax-test-line-continuations
ng-syntax-test-grammar_layer_does_not_do_live_shell_semantics
ng-syntax-test-directory_semantics_and_autocd
ng-syntax-test_autocd_precedence_prefers_executable_commands_and_aliases
ng-syntax-test_cdpath_is_limited_to_directory_changing_semantics
ng-syntax-test_configurable_directory_changing_commands_resolve_simple_aliases
ng-syntax-test-function-definitions-process-substitutions-and-fd-redirects
ng-syntax-test-anonymous-functions-and-control-flow-command-position
ng-syntax-test-options-volume_specs-and-parameter-expansions
ng-syntax-test-default-rendering-for-commands-options-and-volume-specs
ng-syntax-test-default-rendering-for-paths-globs-redirections-and-directories
ng-syntax-test-paint-preserves-foreign-regions-and-removes-old-ng-regions
ng-syntax-test-paint-preserves-foreign-regions-without-layering-syntax
ng-syntax-test-paint-highlights-outside-foreign-regions
ng-syntax-test-paint-skips-bracketed-paste-regions
ng-syntax-test-paint-highlights-outside-bracketed-paste-range
ng-syntax-test-paint-skips-active-visual-selection
ng-syntax-test-bracketed-paste-pty-keeps-whole-paste-highlighted
ng-syntax-test-pty-renders-autodirectory-with-directory-style
ng-syntax-test-large-buffers-are-skipped

print -r -- "syntax highlighting tests passed"
