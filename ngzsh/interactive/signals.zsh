typeset -gaU ng_winch_functions

TRAPWINCH() {
  local handler
  integer handler_status

  for handler in "${ng_winch_functions[@]}"; do
    (( $+functions[$handler] )) || autoload -Uz "$handler"

    "$handler"
    handler_status=$?

    (( handler_status == 0 )) || return "$handler_status"
  done
}
