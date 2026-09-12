typeset -gaU ng_cd_pre_completion_functions
ng_cd_pre_completion_functions=()

setopt ALWAYS_TO_END
setopt AUTO_LIST
setopt AUTO_MENU
setopt AUTO_PARAM_SLASH
setopt COMPLETE_IN_WORD
setopt PATH_DIRS

unsetopt MENU_COMPLETE

zstyle ':completion:*' completer _complete _approximate
zstyle ':completion:*' menu yes select
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "${NGZSH_CACHE_DIR}/compcache"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}no matches found%f'
zstyle ':completion:*:messages' format '%F{cyan}%d%f'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

autoload -Uz compinit
compinit -d "${NGZSH_CACHE_DIR}/.zcompdump-ngzsh-v2"
