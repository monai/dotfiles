source ~/.zsh/checks.zsh
source ~/.zsh/colors.zsh
source ~/.zsh/setopt.zsh
source ~/.zsh/prompt.zsh
source ~/.zsh/completion.zsh
source ~/.zsh/aliases.zsh
source ~/.zsh/bindkeys.zsh
source ~/.zsh/functions.zsh
source ~/.zsh/history.zsh
source ~/.zsh/hooks.zsh
source ~/.zsh/exports.zsh

# Overrides
if [ -f ~/.zshrc.zsh ]; then
    source ~/.zshrc.zsh
fi

#source  ${HOME}/.dotfiles/z/z.sh
