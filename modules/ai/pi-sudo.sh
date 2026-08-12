#!/bin/sh
# pi sudo wrapper — the sudo pi runs in is this one (installed as
# ~/.local/bin/sudo). NOPASSWD allowlisted commands (systemctl subcommands,
# nixos-rebuild) behave identically: sudo never prompts. For everything else,
# the password prompt goes to the user's terminal via the askpass script and
# never crosses the agent's transcript, tool output, or any file.
set -u

# Overridable for testing; real sudo under NixOS lives in /run/wrappers (setuid).
REAL_SUDO="${PI_SUDO_REAL:-/run/wrappers/bin/sudo}"

# Respect explicit non-interactive / stdin modes: never add askpass there.
for a in "$@"; do
  case "$a" in
    -n | --non-interactive | -S | --stdin | -A | --askpass)
      exec "$REAL_SUDO" "$@"
      ;;
  esac
done

export SUDO_ASKPASS="${SUDO_ASKPASS:-${HOME:-}/.pi/agent/sudo-askpass.sh}"
exec "$REAL_SUDO" -A "$@"