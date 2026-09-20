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

for keymap in viins vicmd; do
  # Movement
  bindkey -M "$keymap" '^A'      beginning-of-line       # cmd + <-; Ctrl + A
  bindkey -M "$keymap" '^E'      end-of-line             # cmd + ->; Ctrl + E
  bindkey -M "$keymap" '^[b'     backward-word           # opt + <-; ESC + b
  bindkey -M "$keymap" '^[f'     forward-word            # opt + ->; ESC + f

  # Character deletion
  bindkey -M "$keymap" '^[[3~'   delete-char             # Del->; CSI 3~
  bindkey -M "$keymap" '^[[3;2~' delete-char             # shift + Del->; CSI 3;2~

  # Word deletion
  bindkey -M "$keymap" '^[^?'    backward-kill-word      # opt + <-Delete; ESC + DEL
  bindkey -M "$keymap" '^[d'     kill-word               # opt + Del->; ESC + d
  bindkey -M "$keymap" '^[[3;3~' kill-word               # opt + Del->; CSI 3;3~
  bindkey -M "$keymap" '^[[3;4~' kill-word               # opt + shift + Del->; CSI 3;4~

  # Line deletion
  bindkey -M "$keymap" '^U'      backward-kill-line      # cmd + <-Delete; Ctrl + U
  bindkey -M "$keymap" '^K'      kill-line               # cmd + Del->; Ctrl + K
  bindkey -M "$keymap" '^[[3;9~' kill-line               # cmd + Del->; CSI 3;9~
  bindkey -M "$keymap" '^[[3;10~' kill-line              # cmd + shift + Del->; CSI 3;10~

  # Undo/redo
  bindkey -M "$keymap" '^_'          undo                # cmd + z; Ctrl + _
  bindkey -M "$keymap" '^X^_'        redo                # cmd + shift + z; Ctrl + X, Ctrl + _
  bindkey -M "$keymap" '^[[122;9u'   undo                # cmd + z; CSI-u
  bindkey -M "$keymap" '^[[122;10u'  redo                # cmd + shift + z; CSI-u
done

bindkey -M viins '^?' backward-delete-char               # <-Delete; DEL
bindkey -M viins '^D' delete-char                        # Del->; Ctrl + D
bindkey -M vicmd 'u'  undo
bindkey -M vicmd '^R' redo

# History substring search
bindkey -M viins '^[[A'  ng-history-substring-search-backward-end
bindkey -M viins '^[[B'  ng-history-substring-search-forward-end

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
