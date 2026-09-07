0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

if [[ ${zsh_loaded_plugins[-1]} != */editor && -z ${fpath[(r)${0:h}/functions]} ]] {
  fpath+=( "${0:h}/functions" )
}

if [[ $PMSPEC != *f* ]] {
  fpath+=( "${0:h}/functions" )
}

typeset -gA Plugins
Plugins[EDITOR_DIR]="${0:h}"

# ----

bindkey -v

# ----

autoload -Uz edit-command-line
zle -N edit-command-line

# bindkey -M vicmd v edit-command-line

# ----

# ^X            - Ctrl + X
# ^[, \e, \033  - ESC, ASCII 27
# ^[[           - ESC followed by [ - Control Sequence Introducer (CSI)

# ---- iTerm natural text editing

# Movement.
bindkey -M viins '^A'     beginning-of-line       # cmd + <-; Ctrl + A
bindkey -M viins '^E'     end-of-line             # cmd + ->; Ctrl + E
bindkey -M viins '^[b'    backward-word           # opt + <-; ESC + b
bindkey -M viins '^[f'    forward-word            # opt + ->; ESC + f

# Character deletion.
bindkey -M viins '^?'     backward-delete-char    # <-Delete; DEL
bindkey -M viins '^D'     delete-char             # Del->; Ctrl + D

# Word deletion.
bindkey -M viins '^[^?'   backward-kill-word      # opt + <-Delete; ESC + DEL
bindkey -M viins '^[d'    kill-word               # opt + Del->; ESC + d

# Line deletion.
bindkey -M viins '^U'     backward-kill-line      # cmd + <-Delete; Ctrl + U
bindkey -M viins '^K'     kill-line               # cmd + Del->; Ctrl + K
bindkey -M viins '^[[3~'  kill-line               # cmd + Del->; CSI 3~

# WORDCHARS='_'

ng-reset-prompt() {
  zle reset-prompt
  zle -R
}
zle -N ng-reset-prompt

typeset -gA editor_info
ng-editor-info() {
  editor_info=()
  if [[ $KEYMAP == 'vicmd' ]]; then
    editor_info[keymap]='N'
  else
    editor_info[keymap]='I'
  fi

  zle ng-reset-prompt
}
zle -N ng-editor-info

zle-line-init() {
  zle ng-editor-info
}
zle -N zle-line-init

zle-line-finish() {
  zle ng-editor-info
}
zle -N zle-line-finish

zle-keymap-select() {
  zle ng-editor-info
}
zle -N zle-keymap-select
