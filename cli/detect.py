"""Environment detection for githelpers."""

import os
import platform
import shutil
import subprocess
import sys


# ── ANSI helpers ──────────────────────────────────────────────────────────

BOLD = "\033[1m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
CYAN = "\033[36m"
RED = "\033[31m"
RESET = "\033[0m"

CHECK = GREEN + "\u2714" + RESET
WARN = YELLOW + "\u26a0" + RESET
CROSS = RED + "\u2718" + RESET


# ── Detection ─────────────────────────────────────────────────────────────

def _run(cmd, **kwargs):
    """Run a command and return stdout, or empty string on failure."""
    try:
        r = subprocess.run(
            cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, **kwargs
        )
        return r.stdout.decode("utf-8", errors="replace").strip()
    except Exception:
        return ""


def detect_shell():
    """Return 'zsh', 'bash', or 'other'."""
    shell = os.environ.get("SHELL", "")
    if "zsh" in shell:
        return "zsh"
    if "bash" in shell:
        return "bash"
    return "other"


def detect_os():
    """Return 'macOS' or 'Linux' (or the raw sysname)."""
    name = platform.system()
    if name == "Darwin":
        return "macOS"
    if name == "Linux":
        return "Linux"
    return name


def detect_git_version():
    """Return the git version string, e.g. '2.39.0', or None."""
    raw = _run(["git", "--version"])
    # "git version 2.39.0"
    parts = raw.split()
    for p in parts:
        if p and p[0].isdigit():
            return p
    return None


def detect_prompt_framework():
    """Detect which prompt framework is active.

    Returns one of: 'oh-my-zsh', 'starship', 'powerlevel10k', 'pure', 'none'.
    """
    # oh-my-zsh
    if os.environ.get("ZSH") or os.path.isdir(os.path.expanduser("~/.oh-my-zsh")):
        return "oh-my-zsh"

    # starship
    if shutil.which("starship"):
        return "starship"

    # powerlevel10k / pure — inspect .zshrc
    zshrc = os.path.expanduser("~/.zshrc")
    zshrc_text = ""
    if os.path.isfile(zshrc):
        try:
            with open(zshrc, "r") as f:
                zshrc_text = f.read()
        except OSError:
            pass

    if os.path.isfile(os.path.expanduser("~/.p10k.zsh")) or "powerlevel10k" in zshrc_text:
        return "powerlevel10k"

    if "prompt pure" in zshrc_text or "sindresorhus/pure" in zshrc_text:
        return "pure"

    return "none"


def detect_git_completions():
    """Return True if git completions are likely already loaded."""
    # oh-my-zsh with git plugin
    zshrc = os.path.expanduser("~/.zshrc")
    if os.path.isfile(zshrc):
        try:
            with open(zshrc, "r") as f:
                text = f.read()
            if "plugins=" in text and "git" in text:
                return True
        except OSError:
            pass

    # Check common completion file paths
    completion_paths = [
        "/usr/share/bash-completion/completions/git",
        "/usr/local/share/bash-completion/completions/git",
        "/opt/homebrew/share/bash-completion/completions/git",
        "/usr/share/zsh/site-functions/_git",
        "/usr/local/share/zsh/site-functions/_git",
        "/opt/homebrew/share/zsh/site-functions/_git",
    ]
    for p in completion_paths:
        if os.path.isfile(p):
            return True

    return False


def githelpers_dir():
    """Return the absolute path to the githelpers root directory."""
    return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def detect_all():
    """Run all detection and return a dict of findings."""
    return {
        "shell": detect_shell(),
        "os": detect_os(),
        "git_version": detect_git_version(),
        "prompt_framework": detect_prompt_framework(),
        "git_completions": detect_git_completions(),
        "githelpers_dir": githelpers_dir(),
        "python_version": "{}.{}.{}".format(*sys.version_info[:3]),
    }


def print_summary(info=None):
    """Print a human-readable summary of the detected environment."""
    if info is None:
        info = detect_all()

    print()
    print(BOLD + "Environment" + RESET)
    print("  Shell:            {}".format(info["shell"]))
    print("  OS:               {}".format(info["os"]))
    print("  Git:              {}".format(info["git_version"] or RED + "not found" + RESET))
    print("  Python:           {}".format(info["python_version"]))
    print("  Prompt framework: {}".format(info["prompt_framework"]))
    print("  Git completions:  {}".format(
        CHECK + " available" if info["git_completions"] else YELLOW + "not detected" + RESET
    ))
    print("  Install dir:      {}".format(info["githelpers_dir"]))
    print()
