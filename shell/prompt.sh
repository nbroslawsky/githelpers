# Git prompt integration - framework aware
# Skips setup if a prompt framework is already managing the prompt

_githelpers_detect_prompt_framework() {
    # oh-my-zsh
    if [ -n "$ZSH" ] && [ -d "$ZSH" ]; then
        echo "ohmyzsh"
        return
    fi

    # starship - check both the env var (set after init) and the binary
    # (present if the user intends to use it, even if init hasn't run yet)
    if command -v starship >/dev/null 2>&1 && [ -n "$STARSHIP_SHELL" ]; then
        echo "starship"
        return
    fi
    if command -v starship >/dev/null 2>&1; then
        echo "starship"
        return
    fi

    # powerlevel10k
    if [ "$ZSH_THEME" = "powerlevel10k/powerlevel10k" ] || [ -f "$HOME/.p10k.zsh" ]; then
        echo "p10k"
        return
    fi

    # pure
    if [ -n "$ZSH_VERSION" ]; then
        if typeset -f prompt_pure_setup >/dev/null 2>&1; then
            echo "pure"
            return
        fi
    fi

    echo "none"
}

_githelpers_setup_prompt() {
    local framework
    framework="$(_githelpers_detect_prompt_framework)"

    if [ "$framework" != "none" ]; then
        # Framework detected - don't touch the prompt
        return
    fi

    # Try to find __git_ps1 if not already available
    if ! type __git_ps1 >/dev/null 2>&1; then
        local search_paths=(
            "/usr/share/git-core/contrib/completion/git-prompt.sh"
            "/usr/local/etc/bash_completion.d/git-prompt.sh"
            "/usr/lib/git-core/git-sh-prompt"
            "/opt/homebrew/etc/bash_completion.d/git-prompt.sh"
            "/opt/homebrew/share/git-core/contrib/completion/git-prompt.sh"
        )

        # Try homebrew prefix if available
        if command -v brew >/dev/null 2>&1; then
            local brew_prefix
            brew_prefix="$(brew --prefix 2>/dev/null)"
            if [ -n "$brew_prefix" ]; then
                search_paths+=(
                    "$brew_prefix/etc/bash_completion.d/git-prompt.sh"
                    "$brew_prefix/share/git-core/contrib/completion/git-prompt.sh"
                )
            fi
        fi

        for p in "${search_paths[@]}"; do
            if [ -f "$p" ]; then
                source "$p"
                break
            fi
        done
    fi

    # Configure git prompt indicators
    export GIT_PS1_SHOWDIRTYSTATE=1
    export GIT_PS1_SHOWSTASHSTATE=1
    export GIT_PS1_SHOWUNTRACKEDFILES=1
    export GIT_PS1_SHOWUPSTREAM="auto"

    # If __git_ps1 is available, enhance the prompt
    if type __git_ps1 >/dev/null 2>&1; then
        if [ -n "$BASH_VERSION" ]; then
            # Only modify if PS1 doesn't already include __git_ps1
            case "$PS1" in
                *__git_ps1*) ;;
                *)
                    PS1="${PS1%\\$ } \[\033[0;36m\]\$(__git_ps1 '(%s)')\[\033[0m\] \$ "
                    ;;
            esac
        elif [ -n "$ZSH_VERSION" ]; then
            # For zsh, set RPROMPT if it doesn't already have git info
            if [[ "$PROMPT" != *'git_ps1'* ]] && [[ "$PROMPT" != *'vcs_info'* ]]; then
                setopt PROMPT_SUBST
                RPROMPT='%F{cyan}$(__git_ps1 "(%s)")%f'
            fi
        fi
    else
        # Minimal fallback: just show branch name
        _githelpers_branch_prompt() {
            local branch
            branch="$(git branch --show-current 2>/dev/null)"
            if [ -n "$branch" ]; then
                echo "($branch) "
            fi
        }

        if [ -n "$BASH_VERSION" ]; then
            case "$PS1" in
                *githelpers_branch*) ;;
                *)
                    PS1="${PS1%\\$ } \[\033[0;36m\]\$(_githelpers_branch_prompt)\[\033[0m\]\$ "
                    ;;
            esac
        elif [ -n "$ZSH_VERSION" ]; then
            setopt PROMPT_SUBST
            RPROMPT='%F{cyan}$(_githelpers_branch_prompt)%f'
        fi
    fi
}

_githelpers_setup_prompt
