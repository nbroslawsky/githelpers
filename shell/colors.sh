# ANSI color codes for githelpers
# These are raw codes - use _githelpers_prompt_wrap for PS1 usage

GITHELPERS_RESET=$'\033[0m'
GITHELPERS_BOLD=$'\033[1m'
GITHELPERS_RED=$'\033[0;31m'
GITHELPERS_GREEN=$'\033[0;32m'
GITHELPERS_YELLOW=$'\033[0;33m'
GITHELPERS_BLUE=$'\033[0;34m'
GITHELPERS_CYAN=$'\033[0;36m'
GITHELPERS_WHITE=$'\033[0;37m'

# Wrap a color code for safe use in PS1/PROMPT
# Bash needs \[...\], zsh needs %{...%}
_githelpers_prompt_wrap() {
    if [ -n "$ZSH_VERSION" ]; then
        echo "%{$1%}"
    else
        echo "\\[$1\\]"
    fi
}
