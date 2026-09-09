typeset -g _history_searching
typeset -g _history_savecursor
typeset -g _history_native_mode=0

typeset -g _history_substring_query
typeset -g _history_substring_original_buffer
typeset -g _history_substring_original_cursor
typeset -g _history_substring_index
typeset -ga _history_substring_matches

_history_substring_reset() {
  _history_substring_query=''
  _history_substring_original_buffer=''
  _history_substring_original_cursor=0
  _history_substring_index=0
  _history_substring_matches=()
}

_history_substring_collect() {
  _history_substring_query="$LBUFFER"
  _history_substring_original_buffer="$BUFFER"
  _history_substring_original_cursor=$CURSOR
  _history_substring_index=0
  _history_substring_matches=()

  local line
  local query_lc="${_history_substring_query:l}"

  for line in ${(f)"$(fc -rl -n 1)"}; do
    [[ "$line" == "$_history_substring_original_buffer" ]] && continue

    [[ "${line:l}" == *"$query_lc"* ]] &&
      _history_substring_matches+=("$line")
  done
}

_history_substring_backward() {
  if (( _history_substring_index < ${#_history_substring_matches} )); then
    (( _history_substring_index++ ))
    BUFFER="${_history_substring_matches[_history_substring_index]}"
    CURSOR=${#BUFFER}
    return 0
  fi

  return 1
}

_history_substring_forward() {
  if (( _history_substring_index > 1 )); then
    (( _history_substring_index-- ))
    BUFFER="${_history_substring_matches[_history_substring_index]}"
    CURSOR=${#BUFFER}
    return 0
  fi

  if (( _history_substring_index == 1 )); then
    _history_substring_index=0
    BUFFER="$_history_substring_original_buffer"
    CURSOR=$_history_substring_original_cursor
    return 0
  fi

  return 1
}

_history_up_line_or_substring_search() {
  emulate -L zsh
  typeset -g _history_searching _history_savecursor _history_native_mode

  # If this sequence started on an empty prompt, keep using native history.
  if (( _history_native_mode )); then
    if [[ $LASTWIDGET = _history_up_line_or_substring_search ||
          $LASTWIDGET = _history_down_line_or_substring_search ]]
    then
      zle .up-line-or-history
      return
    fi

    _history_native_mode=0
  fi

  # Starting from an empty prompt activates native-history mode.
  if [[ -z $BUFFER ]]; then
    _history_searching=''
    _history_substring_reset
    _history_native_mode=1
    zle .up-line-or-history
    return
  fi

  if [[ $LBUFFER == *$'\n'* ]]; then
    zle .up-line-or-history
    _history_searching=''
    _history_substring_reset

  elif [[ -n $PREBUFFER ]] &&
    zstyle -t ':zle:_history_up_line_or_substring_search' edit-buffer
  then
    zle .push-line-or-edit

  else
    _history_native_mode=0

    if [[ $LASTWIDGET != $_history_searching ]]; then
      _history_savecursor=$CURSOR
      _history_searching=$WIDGET
      _history_substring_collect
    else
      CURSOR=$_history_savecursor
    fi

    if _history_substring_backward; then
      zstyle -T ':zle:_history_up_line_or_substring_search' leave-cursor &&
        zle .end-of-line
    fi
  fi
}

_history_down_line_or_substring_search() {
  emulate -L zsh
  typeset -g _history_searching _history_savecursor _history_native_mode

  # Continue native history navigation if it started from an empty prompt.
  if (( _history_native_mode )); then
    if [[ $LASTWIDGET = _history_up_line_or_substring_search ||
          $LASTWIDGET = _history_down_line_or_substring_search ]]
    then
      zle .down-line-or-history
      return
    fi

    _history_native_mode=0
  fi

  if [[ -z $BUFFER ]]; then
    _history_searching=''
    _history_substring_reset
    _history_native_mode=1
    zle .down-line-or-history
    return
  fi

  _history_native_mode=0

  if [[ ${+NUMERIC} -eq 0 &&
    ( $LASTWIDGET = $_history_searching || $RBUFFER != *$'\n'* ) ]]
  then
    [[ $LASTWIDGET = $_history_searching ]] &&
      CURSOR=$_history_savecursor

    _history_searching=$WIDGET
    _history_savecursor=$CURSOR

    if _history_substring_forward; then
      if [[ $RBUFFER != *$'\n'* ]]; then
        zstyle -T ':zle:_history_down_line_or_substring_search' leave-cursor &&
          zle .end-of-line
      fi
      return
    fi

    [[ $RBUFFER = *$'\n'* ]] || return
  fi

  _history_searching=''
  _history_substring_reset
  zle .down-line-or-history
}

zle -N _history_up_line_or_substring_search
zle -N _history_down_line_or_substring_search

bindkey '^[[A' _history_up_line_or_substring_search
bindkey '^[[B' _history_down_line_or_substring_search
