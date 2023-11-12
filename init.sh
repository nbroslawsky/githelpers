#!/bin/zsh

DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
source $DIR/colors
source $DIR/git-completion.bash
source $DIR/git-prompt.sh
source $DIR/git-helper.sh

GIT_PS1_SHOWDIRTYSTATE=1
