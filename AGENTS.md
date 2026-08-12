# Dotfiles Project Instructions

Project-specific workflow for this dotfiles repo (loaded by pi only when working inside this project). General instructions live in the global AGENTS.md; this file overrides/extends them for NixOS work here.

## NixOS

- Stage all changes first: `git add -A` — staging makes files git-tracked so `import-tree` detects them.
- Then only run the commands for what actually changed (check with `git diff --staged --name-only`):
  - Only home modules changed (e.g. `modules/home/`, `modules/ai/`) → run `home-manager switch --flake ~/dotfiles` and stop there — no nixos-rebuild needed.
  - Only NixOS modules changed (e.g. `modules/system/`, `modules/hosts/`, `modules/hardware/`, `modules/services/`, `modules/generic/`) → verify with `nixos-rebuild build --flake ~/dotfiles`, then apply with `sudo nixos-rebuild switch --flake ~/dotfiles` (passwordless via the restricted sudo rule). No home-manager needed.
  - Both changed → run both: `home-manager switch`, then `nixos-rebuild build` + `sudo nixos-rebuild switch`.
- Prefer overlays for package modifications
- Use nix-shell to install temporary packages and create temporary dev shells for testing
