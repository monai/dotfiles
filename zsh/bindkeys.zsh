# To see the key combo you want to use just do:
# cat > /dev/null
# And press it

bindkey -v   # Default to standard vi bindings, regardless of editor string

bindkey "^[^[[D"    backward-word   # alt + <-
bindkey "^[[1;5D"   backward-word
bindkey "^[^[[C"    forward-word    # alt + ->
bindkey "^[[1;5C"   forward-word

bindkey "^[[5~"     up-line-or-history
bindkey "^[[6~"     down-line-or-history

bindkey "^[[H"      beginning-of-line
bindkey "^[[1~"     beginning-of-line
bindkey "^[OH"      beginning-of-line
bindkey "^[[F"      end-of-line
bindkey "^[[4~"     end-of-line
bindkey "^[OF"      end-of-line
bindkey " "         magic-space

bindkey "^?"        backward-delete-char
bindkey "^[[3~"     delete-char
bindkey "^[3;5~"    delete-char
bindkey "\e[3~"     delete-char

