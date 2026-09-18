autoload -Uz ng-directory-changing-command ng-directory-resolve ng-syntax-highlight ng-syntax-highlight-spans ng-syntax-grammar-spans ng-syntax-shell-spans

if (( ! ${+NG_DIRECTORY_CHANGING_COMMANDS} )); then
  typeset -ga NG_DIRECTORY_CHANGING_COMMANDS=( cd chdir pushd ng-frequent-directories-jump )
else
  typeset -ga NG_DIRECTORY_CHANGING_COMMANDS
fi

ng-syntax-highlight-pre-redraw() {
  ng-syntax-highlight
}
zle -N zle-line-pre-redraw ng-syntax-highlight-pre-redraw
