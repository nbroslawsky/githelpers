# Git completion loading - framework aware
# Skips if completions are already available

_githelpers_setup_completions() {
    # Check if git completions are already loaded
    if [ -n "$BASH_VERSION" ]; then
        if type __git_complete >/dev/null 2>&1 || type _git >/dev/null 2>&1; then
            return
        fi
    elif [ -n "$ZSH_VERSION" ]; then
        # In zsh, oh-my-zsh and similar load completions automatically
        if [ -n "$ZSH" ] && [ -d "$ZSH" ]; then
            return
        fi
        # Check if _git completion function exists
        if typeset -f _git >/dev/null 2>&1; then
            return
        fi
    fi

    # Try to source from known system paths
    local search_paths=(
        "/usr/share/bash-completion/completions/git"
        "/usr/local/etc/bash_completion.d/git-completion.bash"
        "/opt/homebrew/etc/bash_completion.d/git-completion.bash"
        "/opt/homebrew/share/git-core/contrib/completion/git-completion.bash"
    )

    if command -v brew >/dev/null 2>&1; then
        local brew_prefix
        brew_prefix="$(brew --prefix 2>/dev/null)"
        if [ -n "$brew_prefix" ]; then
            search_paths+=(
                "$brew_prefix/etc/bash_completion.d/git-completion.bash"
                "$brew_prefix/share/git-core/contrib/completion/git-completion.bash"
            )
        fi
    fi

    for p in "${search_paths[@]}"; do
        if [ -f "$p" ]; then
            source "$p"
            return
        fi
    done

    # For zsh, try to initialize the completion system if not already done
    if [ -n "$ZSH_VERSION" ]; then
        if ! typeset -f compinit >/dev/null 2>&1; then
            autoload -Uz compinit
            compinit -i
        fi
    fi
}

_githelpers_setup_completions
