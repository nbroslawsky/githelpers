# githelpers

A collection of git aliases, shell functions, and prompt enhancements for a better git workflow. Works with bash and zsh, and plays nicely with oh-my-zsh, starship, powerlevel10k, and other prompt frameworks.

## Quick Install

```bash
git clone git@github.com:nbroslawsky/githelpers.git ~/githelpers
cd ~/githelpers
./setup.sh
```

The interactive setup detects your shell and environment, then lets you choose which features to enable.

## What You Get

### Git Aliases

Included via `git config --global include.path`:

| Alias | Command | Description |
|-------|---------|-------------|
| `co` | `checkout` | Switch branches |
| `sw` | `switch` | Modern branch switching |
| `st` | `status` | Repository status |
| `ci` | `commit` | Commit changes |
| `br` | `branch` | List/manage branches |
| `lg` | `log --graph ...` | Pretty commit graph |
| `last` | `log -1 --decorate` | Show last commit |
| `day` | `lg --since=yesterday` | Commits from yesterday |
| `week` | `lg --since='last week'` | Commits from last week |
| `month` | `lg --since='last month'` | Commits from last month |
| `search` | `grep -i --color -n` | Case-insensitive search |
| `search-literal` | `grep --color -n` | Case-sensitive search |
| `ready` | compare with upstream | Commits ready to push |
| `pruny` | prune + cleanup | Remove stale remote branches |
| `unstage` | `reset HEAD --` | Unstage files |
| `amend` | `commit --amend --no-edit` | Amend last commit |
| `stash-all` | `stash push --include-untracked` | Stash everything |
| `wip` | add all + WIP commit | Quick work-in-progress save |
| `unwip` | undo WIP commit | Undo a WIP commit |
| `aliases` | list all aliases | Show all configured aliases |
| `branches` | branches by date | List branches by recent activity |

### Shell Aliases (opt-in)

Short shell-level shortcuts: `g=git`, `gs='git st'`, `gl='git lg'`, `gco='git co'`, `gd='git diff'`, `gp='git push'`, `gpl='git pull'`, and more.

### Helper Functions

- `git_main_branch` - Detect whether the repo uses `main` or `master`
- `git_current_branch` - Print the current branch name
- `git_cleanup_branches` - Delete local branches merged into main (dry-run by default, `-f` to execute)
- `git_recent_branches` - Show recently checked-out branches
- `git_search_replace <pattern> <replacement>` - Find and replace across git-tracked files
- `git_open` - Open the repo's remote URL in your browser

### Prompt Integration

If you use oh-my-zsh, starship, powerlevel10k, or pure, githelpers detects this and leaves your prompt alone. If you don't have a prompt framework, it can add git branch/status info to your prompt.

## Managing Your Setup

```bash
githelpers status     # Show what's installed and active
githelpers list       # Show all git aliases
githelpers doctor     # Run diagnostic checks
githelpers enable X   # Enable a module (aliases, functions, prompt, completions)
githelpers disable X  # Disable a module
githelpers setup      # Re-run the setup wizard
githelpers uninstall  # Clean removal
```

## Modules

| Module | Default | Description |
|--------|---------|-------------|
| `aliases` | off | Shell-level shortcuts (g, gs, gco, etc.) |
| `functions` | on | Git helper functions |
| `prompt` | on* | Git prompt integration (*auto-skipped if framework detected) |
| `completions` | on* | Git tab completions (*auto-skipped if already available) |

Git aliases (the `gitconfig` include) are always installed separately via `git config` and are independent of the shell modules.

## Upgrading from the Old Version

If you previously had `source ~/githelpers/init.sh` in your profile, it still works. After `git pull`, you'll see a one-time message about the new setup. Run `./setup.sh` when you're ready to switch to the new modular system.

## Uninstalling

```bash
githelpers uninstall
```

This removes the source line from your shell profile, the gitconfig include, and the config file. To fully remove the repo:

```bash
rm -rf ~/githelpers
```
