HISTSIZE=100000
SAVEHIST=$HISTSIZE
HISTFILE="${NGZSH_STATE_DIR}/history"

setopt EXTENDED_HISTORY
setopt HIST_BEEP
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt SHARE_HISTORY

autoload -Uz ng-history-substring-search-end

zle -N ng-history-substring-search-backward-end ng-history-substring-search-end
zle -N ng-history-substring-search-forward-end ng-history-substring-search-end
