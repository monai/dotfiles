autoload colors;
colors

# Color variables for prompt.
# The variables are wrapped in %{%}. This should be the case for every variable that does not contain space.
for COLOR in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
    eval PR_$COLOR='%{$fg_no_bold[${(L)COLOR}]%}'
    eval PR_BOLD_$COLOR='%{$fg_bold[${(L)COLOR}]%}'
done
eval PR_RESET='$reset_color'

CLICOLOR=1
LSCOLORS=exfxcxdxbxegedabagacad
LS_COLORS='di=34;50:ln=35;50:so=32;50:pi=33;50:ex=31;50:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:'

GREP_OPTIONS='--color=auto'
GREP_COLOR='3;33'
