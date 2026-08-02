# https://zsh.sourceforge.io/Intro/intro_3.html#SEC3

# There are five startup files that zsh will read commands from:

# $ZDOTDIR/.zshenv
# $ZDOTDIR/.zprofile
# $ZDOTDIR/.zshrc
# $ZDOTDIR/.zlogin
# $ZDOTDIR/.zlogout

# If ZDOTDIR is not set, then the value of HOME is used; this is the usual case.

# `.zshenv' is sourced on all invocations of the shell, unless the -f option is set.
# It should contain commands to set the command search path, plus other important environment variables.
# `.zshenv' should not contain commands that produce output or assume the shell is attached to a tty.

# `.zshrc' is sourced in interactive shells. It should contain commands to
# set up aliases, functions, options, key bindings, etc.

# `.zlogin' is sourced in login shells. It should contain commands that should be
# executed only in login shells.
# `.zlogout' is sourced when login shells exit.

# `.zprofile' is similar to `.zlogin', except that it is sourced before `.zshrc'.
# `.zprofile' is meant as an alternative to `.zlogin' for ksh fans;
# the two are not intended to be used together, although this could certainly be done if desired.
# `.zlogin' is not the place for alias definitions, options, environment variable settings, etc.;
# as a general rule, it should not change the shell environment at all. Rather, it should be used to
# set the terminal type and run a series of external commands (fortune, msgs, etc).

# Last login: Sun Apr 13 10:46:10 on ttys002
# zshenv
# zprofile
# zshrc
# zlogin

# $ zsh
# zshenv
# zshrc

echo "zshenv"

# MARK: NGZsh

if [ -z $NGZSHDIR ]; then
  export NGZSHDIR="${0:a:h:h}"
fi

if [ -z $ZDOTDIR ]; then
  export ZDOTDIR="${NGZSHDIR}/runcoms"
fi

# MARK: XDG

if [ -z $XDG_DATA_HOME]; then
  export XDG_DATA_HOME="${HOME}/.local/share"
fi

if [ -z $XDG_CONFIG_HOME]; then
  export XDG_CONFIG_HOME="${HOME}/.config"
fi

if [ -z $XDG_STATE_HOME]; then
  export XDG_STATE_HOME="${HOME}/.local/state"
fi

xdg_bin="${HOME}/.local/bin"

typeset -gUT XDG_DATA_DIRS xdg_data_dirs
typeset -gUT XDG_CONFIG_DIRS xdg_config_dirs

# MARK: Paths

typeset -gU \
  cdpath \
  fpath \
  mailpath \
  manpath \
  manpath_original \
  path \
  path_original

typeset -gUT INFOPATH infopath

cdpath=(
  .
  ~
)

fpath=(
  /opt/homebrew/share/zsh/site-functions
  $fpath
)

path=(
  $xdg_bin
  /opt/homebrew/{bin,sbin}
  /usr/local/{bin,sbin}
  /usr/{bin,sbin}
  /{bin,sbin}
)

infopath=(
  /opt/homebrew/share/info
  /usr/local/share/info
  /usr/share/info
)

# macOS path_helper fix
typeset -gU path_original manpath_original
path_original=($path)
manpath_original=($manpath)

# MARK: Integrations

export ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX=1

# MARK: Telemetry

export DOTNET_CLI_TELEMETRY_OPTOUT=1
export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1
export HOMEBREW_NO_ANALYTICS=1
