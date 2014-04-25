# http://blog.joshdick.net/2012/12/30/my_git_prompt_for_zsh.html
# copied from https://gist.github.com/4415470
# Adapted from code found at <https://gist.github.com/1712320>.

# Modify the colors and symbols in these variables as desired.
GIT_PROMPT_PREFIX="${PR_GREEN}[${PR_RESET}"
GIT_PROMPT_SUFFIX="${PR_GREEN}]${PR_RESET}"
GIT_PROMPT_AHEAD="${PR_RED}ANUM${PR_RESET}"
GIT_PROMPT_BEHIND="${PR_CYAN}BNUM${PR_RESET}"
GIT_PROMPT_MERGING="$FX[bold]${PR__MAGENTA}⚡︎${PR_RESET}"
GIT_PROMPT_UNTRACKED="$FX[bold]${PR_RED}u${PR_RESET}"
GIT_PROMPT_MODIFIED="$FX[bold]${PR_YELLOW}d${PR_RESET}"
GIT_PROMPT_STAGED="$FX[bold]${PR_GREEN}s${PR_RESET}"

# Show Git branch/tag, or name-rev if on detached head
function parse_git_branch() {
    (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

# Show different symbols as appropriate for various Git repository states
function parse_git_state() {
    # Compose this value via multiple conditional appends.
    local GIT_STATE=""
    
    local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
    if [ "${NUM_AHEAD}" -gt 0 ]; then
        GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
    fi
    
    local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
    if [ "${NUM_BEHIND}" -gt 0 ]; then
        GIT_STATE=$GIT_STATE${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
    fi
    
    local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
    if [ -n "${GIT_DIR}" ] && test -r $GIT_DIR/MERGE_HEAD; then
        GIT_STATE=$GIT_STATE$GIT_PROMPT_MERGING
    fi
    
    if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
        GIT_STATE=$GIT_STATE$GIT_PROMPT_UNTRACKED
    fi
    
    if ! git diff --quiet 2> /dev/null; then
        GIT_STATE=$GIT_STATE$GIT_PROMPT_MODIFIED
    fi
    
    if ! git diff --cached --quiet 2> /dev/null; then
        GIT_STATE=$GIT_STATE$GIT_PROMPT_STAGED
    fi
    
    if [[ -n "${GIT_STATE}" ]]; then
        echo " ${GIT_PROMPT_PREFIX}${GIT_STATE}${GIT_PROMPT_SUFFIX}"
    fi
}

# If inside a Git repository, print its branch and state
function git_prompt_string() {
    local git_where="$(parse_git_branch)"
    local git_state="$(parse_git_state)"
    if [ -n "${git_where}" ]; then
        echo "${PR_BLUE}(${git_where#(refs/heads/|tags/)})${git_state}${PR_RESET} "
    fi
}

function virtualenv_info() {
    if [ $VIRTUAL_ENV ]; then
        echo "$PR_LCYAN($(basename $VIRTUAL_ENV))${PR_RESET} "
    fi
}

function line_prompt() {
    echo "${PR_WHITE}${(l:$COLUMNS::―:)}${PR_RESET}\n"
}

function sudo_prompt() {
    if [ ! -z "${SUDO_USER}" -a "${USER}" != "${SUDO_USER}" ]; then
        echo "${PR_RED}#${PR_RESET} "
    fi
}

function ssh_prompt() {
    if [ ! -z "${SSH_CLIENT}" ]; then
        echo "${PR_GREEN}@${PR_RESET} "
    fi
}

PROMPT=''
PROMPT+='$(line_prompt)'
PROMPT+='$(sudo_prompt)'
PROMPT+='$(ssh_prompt)'
PROMPT+='$(virtualenv_info)'
PROMPT+='%~ $(git_prompt_string)'

SPROMPT="Correct ${PR_RED}%R${PR_RESET} to ${PR_GREEN}%r${PR_RESET} [(y)es (n)o (a)bort (e)dit]? "
