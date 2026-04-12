#!/usr/bin/env bash
# githelpers setup - interactive installer
set -e

GITHELPERS_ROOT="$(cd "$(dirname "$0")" && pwd)"

# Check for Python 3
if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 is required but not found."
    echo "Install Python 3.7+ and try again."
    exit 1
fi

# Check Python version
python_version=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
python_major=$(echo "$python_version" | cut -d. -f1)
python_minor=$(echo "$python_version" | cut -d. -f2)

if [ "$python_major" -lt 3 ] || { [ "$python_major" -eq 3 ] && [ "$python_minor" -lt 7 ]; }; then
    echo "Error: Python 3.7+ required, found Python $python_version"
    exit 1
fi

cd "$GITHELPERS_ROOT" && exec python3 -m cli setup
