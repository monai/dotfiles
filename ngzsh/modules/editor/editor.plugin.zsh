# -*- mode: sh; sh-indentation: 4; indent-tabs-mode: nil; sh-basic-offset: 4; -*-

# According to the Zsh Plugin Standard:
# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html

0=${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}
0=${${(M)0:#/*}:-$PWD/$0}

# Then ${0:h} to get plugin's directory

if [[ ${zsh_loaded_plugins[-1]} != */editor && -z ${fpath[(r)${0:h}]} ]] {
    fpath+=( "${0:h}/functions" )
}

# Standard hash for plugins, to not pollute the namespace
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

bindkey -M viins '^[b'    vi-backward-word        # opt + <-; ESC + b
bindkey -M viins '^[f'    vi-forward-word         # opt + ->; ESC + f
bindkey -M viins '^A'     vi-beginning-of-line    # cmd + <-; Ctrl + A
bindkey -M viins '^E'     vi-end-of-line          # cmd + ->; Ctrl + E

bindkey -M viins '^[^?'   vi-backward-kill-word   # opt + <-Delete;   ESC + Backspace
# bindkey -M viins '\x15' backward-kill-line        # cmd + <-Delete; ???

bindkey -M viins '^D'     vi-delete-char          # Del->;        Ctrl + D
bindkey -M viins '^[d'    kill-word               # opt + Del->;  ESC + d

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

# Enables terminal application mode and updates editor information.
zle-line-init() {
  # if (( $+terminfo[smkx] )); then
  #   # Enable terminal application mode.
  #   echoti smkx
  # fi

  zle ng-editor-info
}
zle -N zle-line-init

# Disables terminal application mode and updates editor information.
zle-line-finish() {
  # if (( $+terminfo[rmkx] )); then
  #   # Disable terminal application mode.
  #   echoti rmkx
  # fi

  zle ng-editor-info
}
zle -N zle-line-finish

zle-keymap-select() {
  zle ng-editor-info
}
zle -N zle-keymap-select
