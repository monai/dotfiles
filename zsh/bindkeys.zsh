# To see the key combo you want to use just do:
# cat > /dev/null
# And press it

bindkey -v   # Default to standard vi bindings, regardless of editor string

bindkey '^[^[[D'    backward-word   # alt + <-
bindkey '^[[1;5D'   backward-word
bindkey '^[b'       backward-word
bindkey '^[^[[C'    forward-word    # alt + ->
bindkey '^[[1;5C'   forward-word
bindkey '^[f'       forward-word

bindkey '^[[A'      up-line-or-search
bindkey '^[[B'      down-line-or-search
bindkey '^[[5~'     up-line-or-history
bindkey '^[[6~'     down-line-or-history

bindkey '^[[H'      beginning-of-line
bindkey '^[[1~'     beginning-of-line
bindkey '^[OH'      beginning-of-line
bindkey '^[[F'      end-of-line
bindkey '^[[4~'     end-of-line
bindkey '^[OF'      end-of-line

bindkey '^?'        backward-delete-char
bindkey '^[[3~'     delete-char
bindkey '^[3;5~'    delete-char

bindkey '^[G'       backward-kill-word
bindkey '^[H'       kill-word
bindkey '^[I'       kill-whole-line

bindkey ' '         magic-space

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
