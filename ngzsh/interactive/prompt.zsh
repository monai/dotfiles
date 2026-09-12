autoload -Uz promptinit
promptinit

autoload -Uz ng-prompt-reset-on-winch
typeset -gaU ng_winch_functions
ng_winch_functions+=( ng-prompt-reset-on-winch )

prompt ng
