# Git helper functions
# Provides utility functions for common git workflows

# Load color definitions
source "$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)/colors.sh"

# --------------------------------------------------------------------------
# git_main_branch - detect the primary branch name (main vs master)
# --------------------------------------------------------------------------
git_main_branch() {
    local branch

    # Try the remote HEAD symbolic ref first
    branch="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|.*/||')"
    if [ -n "$branch" ]; then
        echo "$branch"
        return
    fi

    # Fall back to checking if common branch names exist locally
    if git show-ref --verify --quiet refs/heads/main 2>/dev/null; then
        echo "main"
        return
    fi
    if git show-ref --verify --quiet refs/heads/master 2>/dev/null; then
        echo "master"
        return
    fi

    # Default
    echo "main"
}

# --------------------------------------------------------------------------
# git_current_branch - print the current branch name (git 2.22+)
# --------------------------------------------------------------------------
git_current_branch() {
    git branch --show-current 2>/dev/null
}

# --------------------------------------------------------------------------
# git_cleanup_branches - delete local branches merged into the main branch
#   Without flags: dry-run (list what would be deleted)
#   With -f:       actually delete the branches
# --------------------------------------------------------------------------
git_cleanup_branches() {
    local force=0
    if [ "$1" = "-f" ]; then
        force=1
    fi

    local main
    main="$(git_main_branch)"

    # Collect merged branches, excluding the main branch and current branch
    local branches
    branches="$(git branch --merged "$main" 2>/dev/null | grep -v "^\*" | grep -v "^[[:space:]]*${main}$" | sed 's/^[[:space:]]*//')"

    if [ -z "$branches" ]; then
        echo "${GITHELPERS_GREEN}No merged branches to clean up.${GITHELPERS_RESET}"
        return 0
    fi

    if [ "$force" = "0" ]; then
        echo "${GITHELPERS_YELLOW}Branches merged into ${main} (dry run):${GITHELPERS_RESET}"
        echo "$branches" | while IFS= read -r b; do
            echo "  ${GITHELPERS_CYAN}$b${GITHELPERS_RESET}"
        done
        echo ""
        echo "Run ${GITHELPERS_BOLD}git_cleanup_branches -f${GITHELPERS_RESET} to delete them."
    else
        echo "${GITHELPERS_YELLOW}Deleting branches merged into ${main}:${GITHELPERS_RESET}"
        echo "$branches" | while IFS= read -r b; do
            git branch -d "$b" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo "  ${GITHELPERS_GREEN}Deleted${GITHELPERS_RESET} $b"
            else
                echo "  ${GITHELPERS_RED}Failed${GITHELPERS_RESET} $b"
            fi
        done
    fi
}

# --------------------------------------------------------------------------
# git_recent_branches - show recently checked-out branches
# --------------------------------------------------------------------------
git_recent_branches() {
    git reflog | grep 'checkout: moving' | head -20 \
        | awk '{print $NF}' | awk '!seen[$0]++' | head -10
}

# --------------------------------------------------------------------------
# git_search_replace - find and replace across git-tracked files
#   Usage: git_search_replace <search_pattern> <replacement>
# --------------------------------------------------------------------------
git_search_replace() {
    if [ $# -lt 2 ]; then
        echo "Usage: git_search_replace <search_pattern> <replacement>"
        return 1
    fi

    local search="$1"
    local replace="$2"

    # Find files containing the pattern
    local files
    files="$(git grep -il "$search" 2>/dev/null)"
    if [ -z "$files" ]; then
        echo "${GITHELPERS_YELLOW}No matches found for '${search}'.${GITHELPERS_RESET}"
        return 0
    fi

    # Detect sed flavor: GNU sed supports --version, BSD (macOS) does not
    local sed_inplace
    if sed --version >/dev/null 2>&1; then
        sed_inplace=(-i)
    else
        sed_inplace=(-i '')
    fi

    echo "$files" | while IFS= read -r f; do
        sed "${sed_inplace[@]}" "s|${search}|${replace}|g" "$f"
        echo "  ${GITHELPERS_GREEN}Modified${GITHELPERS_RESET} $f"
    done
}

# --------------------------------------------------------------------------
# git_open - open the repo's remote URL in a browser
# --------------------------------------------------------------------------
git_open() {
    local url
    url="$(git remote get-url origin 2>/dev/null)"
    if [ -z "$url" ]; then
        echo "${GITHELPERS_RED}No remote 'origin' found.${GITHELPERS_RESET}"
        return 1
    fi

    # Convert SSH format to HTTPS
    # git@github.com:user/repo.git -> https://github.com/user/repo
    if [[ "$url" == git@* ]]; then
        url="$(echo "$url" | sed 's|git@\(.*\):\(.*\)|https://\1/\2|')"
    fi

    # Strip .git suffix
    url="${url%.git}"

    echo "${GITHELPERS_CYAN}Opening${GITHELPERS_RESET} $url"

    # Open in browser
    if command -v open >/dev/null 2>&1; then
        open "$url"
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$url"
    else
        echo "${GITHELPERS_YELLOW}Could not detect browser opener. URL: ${url}${GITHELPERS_RESET}"
    fi
}
