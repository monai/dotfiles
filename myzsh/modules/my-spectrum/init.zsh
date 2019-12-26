# Return if requirements are not found.
if [[ "$TERM" == 'dumb' ]]; then
  return 1
fi

typeset -Ag FX FG BG

FX=(
  [reset]="\e[00m"
  [bold]="\e[01m"      [no-bold]="\e[22m"
  [italic]="\e[03m"    [no-italic]="\e[23m"
  [underline]="\e[04m" [no-underline]="\e[24m"
  [blink]="\e[05m"     [no-blink]="\e[25m"
  [reverse]="\e[07m"   [no-reverse]="\e[27m"
)

colors=(black red green yellow blue magenta cyan white)

for color in {1..$#colors}; do
  FG[${colors[$color]}]="\e[$(( 29 + color ))m"
  BG[${colors[$color]}]="\e[$(( 29 + color + 10))m"
  FG[bright_${colors[$color]}]="\e[$(( 89 + color ))m"
  BG[bright_${colors[$color]}]="\e[$(( 89 + color + 10))m"
done

for color in "{000..255}"; do
  FG[$color]="\e[38;5;${color}m"
  BG[$color]="\e[48;5;${color}m"
done

unset color
