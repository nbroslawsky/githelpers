"""Entry point for githelpers CLI: python -m cli"""

import argparse
import sys

from . import __version__


def main():
    parser = argparse.ArgumentParser(
        prog="githelpers",
        description="Manage git aliases, shell helpers, and prompt integration.",
    )
    sub = parser.add_subparsers(dest="command")

    sub.add_parser("setup", help="Interactive setup wizard")
    sub.add_parser("status", help="Show installed components and environment")
    sub.add_parser("list", help="Show all configured git aliases")
    sub.add_parser("doctor", help="Run diagnostic checks")

    enable_p = sub.add_parser("enable", help="Enable a module")
    enable_p.add_argument("module", choices=["aliases", "functions", "prompt", "completions"])

    disable_p = sub.add_parser("disable", help="Disable a module")
    disable_p.add_argument("module", choices=["aliases", "functions", "prompt", "completions"])

    sub.add_parser("uninstall", help="Remove githelpers from your environment")
    sub.add_parser("version", help="Print version")

    args = parser.parse_args()

    if args.command is None:
        parser.print_help()
        sys.exit(0)

    if args.command == "version":
        print("githelpers {}".format(__version__))
        return

    if args.command == "setup":
        from .setup_cmd import run_setup
        run_setup()
    elif args.command == "status":
        from .status_cmd import run_status
        run_status()
    elif args.command == "list":
        from .status_cmd import run_list
        run_list()
    elif args.command == "doctor":
        from .status_cmd import run_doctor
        run_doctor()
    elif args.command == "enable":
        from .status_cmd import run_toggle
        run_toggle(args.module, True)
    elif args.command == "disable":
        from .status_cmd import run_toggle
        run_toggle(args.module, False)
    elif args.command == "uninstall":
        from .uninstall_cmd import run_uninstall
        run_uninstall()


if __name__ == "__main__":
    main()
