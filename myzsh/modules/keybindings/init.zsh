function module_keybindings_init {
  for keymap in 'emacs' 'viins'; do
    bindkey -M $keymap '^[^[[D'  backward-word # alt + <-
    bindkey -M $keymap '^[[1;5D' backward-word
    bindkey -M $keymap '^[b'     backward-word
    bindkey -M $keymap '^[^[[C'  forward-word  # alt + ->
    bindkey -M $keymap '^[[1;5C' forward-word
    bindkey -M $keymap '^[f'     forward-word

    bindkey -M $keymap '^[[A'    up-line-or-search
    bindkey -M $keymap '^[[5~'   up-line-or-history
    bindkey -M $keymap '^[[B'    down-line-or-search
    bindkey -M $keymap '^[[6~'   down-line-or-history
    
    bindkey -M $keymap '^[[H'    beginning-of-line # cmd + <-
    bindkey -M $keymap '^[[1~'   beginning-of-line
    bindkey -M $keymap '^[OH'    beginning-of-line
    bindkey -M $keymap '^[[F'    end-of-line       # cmd + ->
    bindkey -M $keymap '^[[4~'   end-of-line
    bindkey -M $keymap '^[OF'    end-of-line

    bindkey -M $keymap '^?'      backward-delete-char
    bindkey -M $keymap '^[[3~'   delete-char
    bindkey -M $keymap '^[3;5~'  delete-char

    bindkey -M $keymap '^[G'     backward-kill-word # alt + backspace
    bindkey -M $keymap '^[H'     kill-word          # alt + del
    bindkey -M $keymap '^[I'     kill-whole-line    # cmd + backspace

    bindkey -M $keymap ' '       magic-space

    bindkey -M $keymap '^R'      history-incremental-search-backward
  done

  # Keypad
  bindkey -s '^[Op' '0'
  bindkey -s '^[Ol' '.'
  bindkey -s '^[On' '.'
  bindkey -s '^[OM' '^M' # Enter
  bindkey -s '^[Oq' '1'
  bindkey -s '^[Or' '2'
  bindkey -s '^[Os' '3'
  bindkey -s '^[Ot' '4'
  bindkey -s '^[Ou' '5'
  bindkey -s '^[Ov' '6'
  bindkey -s '^[Ow' '7'
  bindkey -s '^[Ox' '8'
  bindkey -s '^[Oy' '9'
  bindkey -s '^[Ok' '+'
  bindkey -s '^[Om' '-'
  bindkey -s '^[Oj' '*'
  bindkey -s '^[Oo' '/'
  bindkey -s '^[OX' '='
}
