setopt BEEP
setopt COMBINING_CHARS

bindkey -v

autoload -Uz edit-command-line
zle -N edit-command-line

bindkey -M vicmd v edit-command-line

# ^X            - Ctrl + X
# ^[, \e, \033  - ESC, ASCII 27
# ^[[           - ESC followed by [ - Control Sequence Introducer (CSI)

# Text editing
#
# Ghostty/xterm-style sequences are treated as the primary terminal behavior.
# iTerm2 Natural Text Editing byte sequences are kept as compatibility aliases.

# Movement
bindkey -M viins '^A'       beginning-of-line
bindkey -M viins '^E'       end-of-line
bindkey -M viins '^[b'      backward-word
bindkey -M viins '^[f'      forward-word

# Character deletion
bindkey -M viins '^?'       backward-delete-char
bindkey -M viins '^D'       delete-char
bindkey -M viins '^[[3~'    delete-char
bindkey -M viins '^[[3;2~'  delete-char

# Word deletion
bindkey -M viins '^[^?'     backward-kill-word
bindkey -M viins '^[d'      kill-word
bindkey -M viins '^[[3;3~'  kill-word
bindkey -M viins '^[[3;4~'  kill-word

# Line deletion
bindkey -M viins '^U'       backward-kill-line
bindkey -M viins '^K'       kill-line
bindkey -M viins '^[[3;9~'  kill-line
bindkey -M viins '^[[3;10~' kill-line

# History substring search
bindkey -M viins '^[[A'  ng-history-substring-search-backward-end
bindkey -M viins '^[[B'  ng-history-substring-search-forward-end

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
