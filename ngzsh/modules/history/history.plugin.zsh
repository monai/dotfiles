typeset -g _ng_history_searching
typeset -g _ng_history_native_mode=0

typeset -g _ng_history_substring_query
typeset -g _ng_history_substring_original_buffer
typeset -g _ng_history_substring_original_cursor
typeset -g _ng_history_substring_index
typeset -ga _ng_history_substring_matches

_ng-history-substring-reset() {
  _ng_history_substring_query=''
  _ng_history_substring_original_buffer=''
  _ng_history_substring_original_cursor=0
  _ng_history_substring_index=0
  _ng_history_substring_matches=()
}

_ng-history-substring-search-widget-p() {
  [[ $1 = ng-history-substring-search-backward-end ||
     $1 = ng-history-substring-search-forward-end ]]
}

_ng-history-substring-collect() {
  _ng_history_substring_query="$LBUFFER"
  _ng_history_substring_original_buffer="$BUFFER"
  _ng_history_substring_original_cursor=$CURSOR
  _ng_history_substring_index=0
  _ng_history_substring_matches=()

  local line
  local query_lc="${_ng_history_substring_query:l}"

  for line in ${(f)"$(fc -rl -n 1)"}; do
    [[ "$line" == "$_ng_history_substring_original_buffer" ]] && continue

    [[ "${line:l}" == *"$query_lc"* ]] &&
      _ng_history_substring_matches+=("$line")
  done
}

_ng-history-substring-backward() {
  if (( _ng_history_substring_index < ${#_ng_history_substring_matches} )); then
    (( _ng_history_substring_index++ ))
    BUFFER="${_ng_history_substring_matches[_ng_history_substring_index]}"
    CURSOR=${#BUFFER}
    return 0
  fi

  return 1
}

_ng-history-substring-forward() {
  if (( _ng_history_substring_index > 1 )); then
    (( _ng_history_substring_index-- ))
    BUFFER="${_ng_history_substring_matches[_ng_history_substring_index]}"
    CURSOR=${#BUFFER}
    return 0
  fi

  if (( _ng_history_substring_index == 1 )); then
    _ng_history_substring_index=0
    BUFFER="$_ng_history_substring_original_buffer"
    CURSOR=$_ng_history_substring_original_cursor
    return 0
  fi

  return 1
}

ng-history-substring-search-backward-end() {
  emulate -L zsh
  typeset -g _ng_history_searching _ng_history_native_mode

  # If this sequence started on an empty prompt, keep using native history.
  if (( _ng_history_native_mode )); then
    if _ng-history-substring-search-widget-p "$LASTWIDGET"; then
      zle .up-line-or-history
      return
    fi

    _ng_history_native_mode=0
  fi

  # Starting from an empty prompt activates native-history mode.
  if [[ -z $BUFFER ]]; then
    _ng_history_searching=''
    _ng-history-substring-reset
    _ng_history_native_mode=1
    zle .up-line-or-history
    return
  fi

  if [[ $LBUFFER == *$'\n'* ]]; then
    zle .up-line-or-history
    _ng_history_searching=''
    _ng-history-substring-reset

  elif [[ -n $PREBUFFER ]] &&
    zstyle -t ':zle:ng-history-substring-search-backward-end' edit-buffer
  then
    zle .push-line-or-edit

  else
    _ng_history_native_mode=0

    if ! _ng-history-substring-search-widget-p "$LASTWIDGET"; then
      _ng-history-substring-collect
    fi

    _ng_history_searching=$WIDGET

    if _ng-history-substring-backward; then
      zstyle -T ':zle:ng-history-substring-search-backward-end' leave-cursor &&
        zle .end-of-line
    fi
  fi
}

ng-history-substring-search-forward-end() {
  emulate -L zsh
  typeset -g _ng_history_searching _ng_history_native_mode

  # Continue native history navigation if it started from an empty prompt.
  if (( _ng_history_native_mode )); then
    if _ng-history-substring-search-widget-p "$LASTWIDGET"; then
      zle .down-line-or-history
      return
    fi

    _ng_history_native_mode=0
  fi

  if [[ -z $BUFFER ]]; then
    _ng_history_searching=''
    _ng-history-substring-reset
    _ng_history_native_mode=1
    zle .down-line-or-history
    return
  fi

  _ng_history_native_mode=0

  if [[ ${+NUMERIC} -eq 0 &&
    ( $LASTWIDGET = $_ng_history_searching || $RBUFFER != *$'\n'* ) ]]
  then
    _ng_history_searching=$WIDGET

    if _ng-history-substring-forward; then
      if [[ $RBUFFER != *$'\n'* ]]; then
        zstyle -T ':zle:ng-history-substring-search-forward-end' leave-cursor &&
          zle .end-of-line
      fi
      return
    fi

    [[ $RBUFFER = *$'\n'* ]] || return
  fi

  _ng_history_searching=''
  _ng-history-substring-reset
  zle .down-line-or-history
}

zle -N ng-history-substring-search-backward-end
zle -N ng-history-substring-search-forward-end

bindkey '^[[A' ng-history-substring-search-backward-end
bindkey '^[[B' ng-history-substring-search-forward-end
