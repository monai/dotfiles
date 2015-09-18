source ~/.zsh/checks.zsh
source ~/.zsh/history.zsh
source ~/.zsh/setopt.zsh
source ~/.zsh/completion.zsh
source ~/.zsh/bindkeys.zsh
source ~/.zsh/colors.zsh
source ~/.zsh/prompt.zsh
source ~/.zsh/aliases.zsh
source ~/.zsh/functions.zsh
source ~/.zsh/hooks.zsh
source ~/.zsh/integration.zsh
source ~/.zsh/exports.zsh

# Overrides
if [ -f ~/.zshrc.zsh ]; then
    source ~/.zshrc.zsh
fi

# Z
if [ -f ~/.zsh/z/z.sh ]; then
    source  ~/.zsh/z/z.sh
fi
