# Return if requirements are not found.
if [[ "${TERM}" == 'dumb' ]]; then
  return 1
fi

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
  reset     "\e[00m"
  bold      "\e[01m" no-bold      "\e[22m"
  italic    "\e[03m" no-italic    "\e[23m"
  underline "\e[04m" no-underline "\e[24m"
  blink     "\e[05m" no-blink     "\e[25m"
  reverse   "\e[07m" no-reverse   "\e[27m"
)

for color in "{000..255}"; do
  FG[$color]="\e[38;5;${color}m"
  BG[$color]="\e[48;5;${color}m"
done

for color in "${(@k)ANSI_COLORS}"; do
  FG[$color]="\e[$ANSI_COLORS[$color]m"
  BG[$color]="\e[$(($ANSI_COLORS[$color] + 10))m"
  FG[$color:l]=$FG[$color]
  BG[$color:l]=$BG[$color]
  eval "PR_${color}='%{$FG[$color]%}'"
done

PR_RESET="%{$FX[reset]%}"
PR_BOLD="%{$FX[bold]%}"
PR_ITALIC="%{$FX[italic]%}"
PR_UNDERLINE="%{$FX[underline]%}"
PR_BLINK="%{$FX[blink]%}"
PR_REVERSE="%{$FX[reverse]%}"

unset color
