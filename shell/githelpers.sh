#!/usr/bin/env bash
# githelpers - modern git workflow enhancements
# Source this file from your shell profile (.bashrc / .zshrc)

# Determine our directory (works in both bash and zsh)
if [ -n "$BASH_VERSION" ]; then
    GITHELPERS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ -n "$ZSH_VERSION" ]; then
    GITHELPERS_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
else
    GITHELPERS_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

# shell/ is inside the repo, so go up one level for the repo root
GITHELPERS_ROOT="$(dirname "$GITHELPERS_DIR")"
export GITHELPERS_DIR GITHELPERS_ROOT

# Config file location
GITHELPERS_CONFIG="$HOME/.githelpers.conf"

# Module defaults: functions on, aliases off, prompt on, completions on
GITHELPERS_MODULE_ALIASES=0
GITHELPERS_MODULE_FUNCTIONS=1
GITHELPERS_MODULE_PROMPT=1
GITHELPERS_MODULE_COMPLETIONS=1

# Read config overrides if present
# The config file uses GITHELPERS_MODULE_*=0|1 format (valid shell syntax).
# We eval only lines matching our prefix for safety.
if [ -f "$GITHELPERS_CONFIG" ]; then
    eval "$(grep '^GITHELPERS_MODULE_' "$GITHELPERS_CONFIG")"
fi

# Source enabled modules
[ "$GITHELPERS_MODULE_ALIASES" = "1" ] && source "$GITHELPERS_DIR/aliases.sh"
[ "$GITHELPERS_MODULE_FUNCTIONS" = "1" ] && source "$GITHELPERS_DIR/functions.sh"
[ "$GITHELPERS_MODULE_PROMPT" = "1" ] && source "$GITHELPERS_DIR/prompt.sh"
[ "$GITHELPERS_MODULE_COMPLETIONS" = "1" ] && source "$GITHELPERS_DIR/completions.sh"

# Add repo root to PATH for the githelpers CLI command
case ":$PATH:" in
    *":$GITHELPERS_ROOT:"*) ;;
    *) export PATH="$GITHELPERS_ROOT:$PATH" ;;
esac
