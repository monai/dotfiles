CLICOLOR=1
LSCOLORS=exfxcxdxbxegedabagacad
LS_COLORS='di=34;50:ln=35;50:so=32;50:pi=33;50:ex=31;50:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:'

GREP_OPTIONS='--color=auto'
GREP_COLOR='3;33'

typeset -Ag ANSI_COLORS FX FG BG

ANSI_COLORS=(
    BLACK   30  LBLACK   90
    RED     31  LRED     91
    GREEN   32  LGREEN   92
    YELLOW  33  LYELLOW  93
    BLUE    34  LBLUE    94
    MAGENTA 35  LMAGENTA 95
    CYAN    36  LCYAN    96
    WHITE   37  LWHITE   97
)

FX=(
    reset     "[00m"
    bold      "[01m" no-bold      "[22m"
    italic    "[03m" no-italic    "[23m"
    underline "[04m" no-underline "[24m"
    blink     "[05m" no-blink     "[25m"
    reverse   "[07m" no-reverse   "[27m"
)

for color in {000..$SUPPORT}; do
    FG[$color]="[38;5;${color}m"
    BG[$color]="[48;5;${color}m"
done

for COLOR in "${(@k)ANSI_COLORS}"; do
    FG[$COLOR]="[$ANSI_COLORS[$COLOR]m"
    BG[$COLOR]="[$(($ANSI_COLORS[$COLOR] + 10))m"
    FG[$COLOR:l]=$FG[$COLOR]
    BG[$COLOR:l]=$BG[$COLOR]
    eval PR_$COLOR='%{$FG[$COLOR]%}'
done
eval PR_RESET='%{$FX[reset]%}'
