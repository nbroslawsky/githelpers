#!/bin/bash
# Backwards-compatible shim for existing users
# New users should source shell/githelpers.sh instead
# See README.md or run ./setup.sh for the new setup experience

GITHELPERS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# Show upgrade notice once
if [ ! -f "$HOME/.githelpers_upgrade_noticed" ]; then
    echo "[githelpers] This repo has been updated with new features!"
    echo "[githelpers] Run: cd $GITHELPERS_DIR && ./setup.sh"
    echo "[githelpers] Your current setup continues to work as-is."
    echo ""
    touch "$HOME/.githelpers_upgrade_noticed"
fi

# Source legacy files (preserves old behavior)
source "$GITHELPERS_DIR/legacy/colors"
source "$GITHELPERS_DIR/legacy/git-completion.bash"
source "$GITHELPERS_DIR/legacy/git-prompt.sh"
source "$GITHELPERS_DIR/legacy/git-helper.sh"
GIT_PS1_SHOWDIRTYSTATE=1
