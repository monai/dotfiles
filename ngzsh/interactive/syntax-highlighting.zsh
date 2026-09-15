autoload -Uz ng-syntax-highlight ng-syntax-highlight-spans

ng-syntax-highlight-pre-redraw() {
  ng-syntax-highlight
}
zle -N zle-line-pre-redraw ng-syntax-highlight-pre-redraw
