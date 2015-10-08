ZAZHIMADIR=${ZDOTDIR:-$HOME}/.zazhima

source $ZAZHIMADIR/vendor/zgen/zgen.zsh

if ! $(zgen saved); then
  echo "Creating a zgen save"
  
  ZGEN_PREZTO_LOAD_DEFAULT=0

  zgen prezto editor key-bindings  'vi'
  zgen prezto editor dot-expansion 'yes'
  zgen prezto prompt theme         'mytheme'
  
  zgen prezto
  
  zgen prezto environment
  zgen prezto terminal
  zgen prezto editor
  zgen prezto history
  zgen prezto utility
  zgen prezto completion
  zgen prezto prompt
  
  zgen prezto git
  zgen prezto ruby
  zgen prezto node
  zgen prezto python
  
  zgen prezto osx
  zgen prezto command-not-found
  zgen prezto syntax-highlighting
  zgen prezto history-substring-search
  
  zgen load $ZAZHIMADIR/modules/checks
  zgen load $ZAZHIMADIR/modules/keybindings
  zgen load $ZAZHIMADIR/modules/spectrum
  zgen load $ZAZHIMADIR/modules/mytheme
  zgen load $ZAZHIMADIR/modules/aliases

  zgen save
fi

module_keybindings_init
module_aliases_init
