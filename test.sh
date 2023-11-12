#!/bin/zsh
function parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1] /p'
}


DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
source $DIR/colors
source $DIR/git-completion.bash
source $DIR/git-prompt.sh
source $DIR/git-helper.sh

GIT_PS1_SHOWDIRTYSTATE=1


COLOR_DEF=$'%f'
COLOR_USR=$'%F{243}'
COLOR_DIR=$'%F{197}'
COLOR_GIT=$'%F{39}'
setopt PROMPT_SUBST
export PROMPT='${YELLOW}%n@%m ${COLOR_USR}%n ${COLOR_DIR}%2~ ${COLOR_GIT}$(parse_git_branch)${COLOR_DEF}$ '
