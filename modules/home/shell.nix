{ lib, ... }:
let
  aliasAbbr = { config, ... }: {
    fetch = "fastfetch";
    nix-clean = "nix-store --optimise && nix-store --gc && nix-collect-garbage -d";
    firstinstall = "bash ${config.home.homeDirectory}/.scripts/firstinstall.sh";
    nv = "nvitop --colorful";
    o = "xdg-open";
    ss = "sudo systemctl-tui";
    s = "systemctl-tui";
    cd = "z";
    rd = "rm -rf ";
    c = "clear";
    q = "exit";
    ch = "cht.sh";
    net = "sudo nethogs";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    code = "codium";
    nos = "nix --extra-experimental-features 'nix-command flakes' search nixpkgs";
    ab = "nixos-rebuild build --flake ~/dotfiles --show-trace";
    abb = "sudo nixos-rebuild boot --flake ~/dotfiles --show-trace";
    ad = "sudo nixos-rebuild dry-build --flake ~/dotfiles --show-trace";
    at = "sudo nixos-rebuild test --flake ~/dotfiles --show-trace";
    as = "sudo nixos-rebuild switch --flake ~/dotfiles --show-trace";
    hb = "home-manager build --flake ~/dotfiles";
    hs = "home-manager switch --flake ~/dotfiles";
    us = "nix flake update --flake ~/dotfiles";

    lsa = "ls -a";
    lsl = "ls -l";
    lsla = "lsl -a";
    ls = "eza -gh --group-directories-first --git --icons --color-scale all --hyperlink";
    list-gen = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
    delete-gen = "sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system";
    clear-boot = "sudo /run/current-system/bin/switch-to-configuration boot";
    gdt = "meld .";
    fzf = "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'";
    np = "nix-shell -p";
    y = "yazi";
    sy = "sudo yazi";
    lg = "lazygit";

    oc = "opencode";
    jl = "journalctl -fu";
    jlu = "journalctl --user -fu";
    cat = "bat";
    rg = "batgrep";
    ripgrep = "batgrep";
    man = "batman";
    h = "herdr";
    btop = "btop --force-utf";
  };
in
{
  flake.homeModules.shell =
    { config, pkgs, ... }:
    with lib;
    let
      alias-abbr = aliasAbbr { inherit config; };
      mkShellIntegration =
        base:
        base
        // {
          enableZshIntegration = true;
          enableBashIntegration = true;
        };
    in
    {

      config = mkMerge [
        {
          programs = {
            zoxide = mkShellIntegration { enable = true; };
            atuin = mkShellIntegration {
              enable = true;
              flags = [ "--disable-ctrl-r" ];
            };
            hstr.enable = false;
            fzf = mkShellIntegration { enable = true; };
            direnv = mkShellIntegration {
              enable = true;
              nix-direnv.enable = true;
            };
            nix-index = mkShellIntegration { enable = true; };
            eza = mkShellIntegration { enable = true; };
            carapace = mkShellIntegration { enable = true; };

          };
        }

        {
          # ~/.local/bin holds symlinks created by `uv tool install` (notebooklm,
          # mcp, ...). Ensure it is on PATH in every managed shell; some configs
          # override ~/.zshrc PATH exports, so declare it here instead.
          home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
        }

        {
          programs.zsh = {
            enable = true;
            autosuggestion.enable = true;
            enableCompletion = true;
            syntaxHighlighting.enable = true;
            history = {
              share = true;
              size = 9999999;
              save = 9999999;
              ignoreDups = true;
              ignoreAllDups = true;
              ignoreSpace = true;
              extended = true;
            };
            dotDir = "${config.xdg.configHome}/zsh";
            envExtra = ''
              setopt no_global_rcs
              setopt INTERACTIVE_COMMENTS
              setopt GLOB_DOTS
              setopt NO_BEEP

              zstyle ':completion:*:descriptions' format '[%d]'
              zstyle ':completion:*' group-name ${"''"}
              zstyle ':completion:*' list-colors ${"''\${(s.:.)LS_COLORS}"}
              zstyle ':completion:*' menu no
            '';
            sessionVariables.EDITOR = "nvim";
            zsh-abbr = {
              enable = true;
              abbreviations = alias-abbr;
            };
            shellAliases = alias-abbr // {
              lst = "lt";
            };
            completionInit = "autoload -Uz compinit && compinit -C";
            initContent = ''
              bash() { command /run/current-system/sw/bin/bash "$@"; }
              j() { systemctl list-units --type=service --all | grep -i "$1"; systemctl --user list-units --type=service --all | grep -i "$1"; }
              lt() { ls --tree --level=''${1:-2}; }
              lsta() { lsa --tree --level=''${1:-2}; }
              [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

              zstyle ':fzf-tab:*' show-group brief

              # uv tool install puts CLIs (notebooklm, mcp, ...) in ~/.local/bin.
              # Plugin managers (zplug/p10k) rebuild PATH after the env files are
              # sourced, so re-add it here (last) so these stay reachable.
              export PATH="$HOME/.local/bin:$PATH"
            '';
            zplug = {
              enable = true;
              plugins = [
                {
                  name = "romkatv/powerlevel10k";
                  tags = [
                    "as:theme"
                    "depth:1"
                  ];
                }
                {
                  name = "Aloxaf/fzf-tab";
                }
              ];
            };
          };
          home.file.".p10k.zsh".source = ./zsh/.p10k.zsh;
        }
        {

          programs.bash = {
            enable = true;
            enableCompletion = true;
            historyControl = [
              "ignoredups"
              "ignorespace"
            ];
            historyFileSize = 9999999;
            historySize = 1000;
            shellAliases = alias-abbr // {
              lst = "function _lt() { ls --tree --level=\${1:-2}; }; _lt";
              lsta = "function _lt() { lsa --tree --level=\${1:-2}; }; _lt";
            };
          };
          programs.oh-my-posh = {
            enable = true;
            enableBashIntegration = true;
            useTheme = "atomic";
            package = pkgs.oh-my-posh;
          };
        }
      ];
    };
}
