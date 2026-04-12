"""Uninstall githelpers from the user's environment."""

import os
import re
import subprocess
import sys

from .detect import (
    BOLD, CHECK, CYAN, GREEN, RED, RESET, WARN, YELLOW,
    detect_all, _run, githelpers_dir,
)


CONF_PATH = os.path.expanduser("~/.githelpers.conf")


def _shell_profile(info):
    """Return the path to the user's shell profile file."""
    shell = info["shell"]
    if shell == "zsh":
        return os.path.expanduser("~/.zshrc")
    if shell == "bash":
        if info["os"] == "macOS":
            return os.path.expanduser("~/.bash_profile")
        return os.path.expanduser("~/.bashrc")
    return os.path.expanduser("~/.profile")


def run_uninstall():
    info = detect_all()
    gh_dir = info["githelpers_dir"]

    print()
    print(BOLD + RED + "=== githelpers uninstall ===" + RESET)
    print()

    try:
        answer = input("Remove githelpers from your environment? [y/N] ").strip().lower()
    except (EOFError, KeyboardInterrupt):
        print()
        sys.exit(1)

    if answer not in ("y", "yes"):
        print("Aborted.")
        return

    # 1. Remove source line from shell profile
    profile = _shell_profile(info)
    source_line = "source {}/shell/githelpers.sh".format(gh_dir)
    if os.path.isfile(profile):
        try:
            with open(profile, "r") as f:
                original = f.read()

            # Remove the source line and the comment before it
            lines = original.splitlines(True)
            new_lines = []
            skip_next = False
            for line in lines:
                if skip_next:
                    skip_next = False
                    if source_line in line:
                        continue  # drop this line
                    else:
                        # The comment wasn't followed by our line — keep both
                        new_lines.append("# githelpers\n")
                        new_lines.append(line)
                        continue
                if line.strip() == "# githelpers":
                    skip_next = True
                    continue
                if source_line in line:
                    continue  # standalone source line without comment
                new_lines.append(line)

            with open(profile, "w") as f:
                f.writelines(new_lines)
            print("  {} Removed source line from {}".format(CHECK, profile))
        except OSError as exc:
            print("  {} Could not update {}: {}".format(WARN, profile, exc))
    else:
        print("  {} Shell profile not found: {}".format(WARN, profile))

    # 2. Remove gitconfig include.path (only if it points to our file)
    gitconfig_path = os.path.join(gh_dir, "gitconfig")
    gitconfig_tilde = gitconfig_path.replace(os.path.expanduser("~"), "~", 1)
    includes = _run(["git", "config", "--global", "--get-all", "include.path"])
    include_lines = includes.splitlines()
    # Find the actual value stored in gitconfig (could be absolute or ~/...)
    actual_include = None
    for line in include_lines:
        if line in (gitconfig_path, gitconfig_tilde):
            actual_include = line
            break
    if actual_include:
        try:
            subprocess.run(
                ["git", "config", "--global", "--unset", "include.path", actual_include],
                check=True,
            )
            print("  {} Removed gitconfig include.path".format(CHECK))
        except subprocess.CalledProcessError:
            print("  {} Could not remove gitconfig include.path".format(WARN))
    else:
        print("  {} No gitconfig include.path to remove".format(WARN))

    # 3. Remove config file
    if os.path.isfile(CONF_PATH):
        os.remove(CONF_PATH)
        print("  {} Removed {}".format(CHECK, CONF_PATH))

    # 4. Remove upgrade notice file
    notice_path = os.path.expanduser("~/.githelpers_upgrade_noticed")
    if os.path.isfile(notice_path):
        os.remove(notice_path)
        print("  {} Removed {}".format(CHECK, notice_path))

    print()
    print(BOLD + GREEN + "Uninstall complete." + RESET)
    print()
    print("The githelpers directory itself was not removed.")
    print("To fully remove it, run:")
    print("  {}rm -rf {}{}".format(CYAN, gh_dir, RESET))
    print()
