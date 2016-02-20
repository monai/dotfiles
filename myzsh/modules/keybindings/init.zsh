# iTerm bindings
#
# http://stackoverflow.com/questions/6205157/iterm2-how-to-get-jump-to-beginning-end-of-line-in-bash-shell/29403520#29403520
#
# cmd + delete      0x0b        // ^K
# cmd + backspace   0x15        // ^U
# opt + delete      0x1b 0x64   // [d,  actual is ^[d
# opt + backspace   0x1b 0x08   // [^H, actual is ^[^H
#
# cmd + <-          0x01        // ^A
# cmd + ->          0x05        // ^E
# opt + <-          0x1b 0x62   // [b, actual is ^[b
# opt + ->          0x1b 0x66   // [f, actual is ^[f
#
# cmd + z           0x1f        // ^_
# cmd + y           0x18 0x1f   // ^X^_
# shift + cmd + z   0x18 0x1f   // ^X^_

module_keybindings_init() {
  for keymap in 'emacs' 'viins'; do
    bindkey -M $keymap '^[[A'    up-line-or-search
    bindkey -M $keymap '^[[5~'   up-line-or-history
    bindkey -M $keymap '^[[B'    down-line-or-search
    bindkey -M $keymap '^[[6~'   down-line-or-history

    bindkey -M $keymap '^[[1;5D' backward-word
    bindkey -M $keymap '^[b'     backward-word
    bindkey -M $keymap '^[[1;5C' forward-word
    bindkey -M $keymap '^[f'     forward-word

    bindkey -M $keymap '^[[1~'   beginning-of-line
    bindkey -M $keymap '^[OH'    beginning-of-line
    bindkey -M $keymap '^A'      beginning-of-line
    bindkey -M $keymap '^[[4~'   end-of-line
    bindkey -M $keymap '^[OF'    end-of-line
    bindkey -M $keymap '^E'      end-of-line

    bindkey -M $keymap '^?'      backward-delete-char
    bindkey -M $keymap '^[[3~'   delete-char
    bindkey -M $keymap '^[3;5~'  delete-char

    bindkey -M $keymap '^[d'     kill-word
    bindkey -M $keymap '^[^H'    backward-kill-word
    bindkey -M $keymap '^K'      kill-line
    bindkey -M $keymap '^U'      backward-kill-line
    
    bindkey -M $keymap '^_'      undo
    bindkey -M $keymap '^X^_'    redo

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
