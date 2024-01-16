{ config, lib, pkgs, ... }:
{

  environment.packages = with pkgs; [
    git
    bat
    nano
    neofetch
    ncdu
    mc
    onefetch
    python311Packages.howdoi
    unzip
    fd
    tree-sitter
    comma
    fontconfig
    htop
    screenfetch
    rnix-lsp
    git
    git-crypt
    gnupg
    wget
    neofetch
    nethogs
    p7zip
    #   yt-dlp
    zoxide
    tgpt
    direnv
    nixpkgs-fmt
    eza
    nixfmt
    cht-sh
    nix-init
    ripgrep
    fzf
    tldr
    lazygit
    curl
    zsh
    starship
    openssh
    any-nix-shell
    perl
    gcc
    zig
    cargo
    pinentry
    nix-index
    utillinux
    bash
    gnumake
    rclone
    ffsend
    thefuck
    python3
    tmux
    ollama
    # oterm
    termdbms
    python311Packages.pudb
    ttyper
    termimage
    helix
    bitwarden-cli

    gpg-tui
    # Read the changelog before changing this value
    # home.stateVersion = "23.05";

    # insert home-manager config
  ];

  time.timeZone = "Asia/Kolkata";
  environment.etcBackupExtension = ".bak";
  system.stateVersion = "23.05";
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  terminal.font =
    let
      firacode = pkgs.nerdfonts.override {
        fonts = [ "FiraCode" ];
      };
      fontPath = "share/fonts/truetype/NerdFonts/FiraCodeNerdFontMono-Regular.ttf";
    in
    "${firacode}/${fontPath}";
  user.shell = "${pkgs.zsh}/bin/zsh";
  home-manager = {
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
    config =
      { config, lib, pkgs, ... }:
      {
        imports = [
          ../../modules/home-manager/git.nix
          ../../modules/home-manager/zsh/zsh.nix
          ../../modules/home-manager/ranger.nix
          ../../modules/home-manager/bat.nix
          ../../modules/home-manager/neovim.nix
          ../../modules/home-manager/tmux.nix
          # ../../modules/home-manager/nvim.nix
          ../../modules/home-manager/yazi.nix
        ];

        modules.home-manager = {
          git.enable = true;
          zsh.enable = true;
          ranger.enable = true;
          bat.enable = true;
          neovim.enable = true;
          tmux.enable = true;
          # nvim.enable = false;
          yazi.enable = true;
        };
        home = {
          username = "nix-on-droid";
          homeDirectory = "/data/data/com.termux.nix/files/home";
          stateVersion = "23.05";
        };
        home.packages = with pkgs; [
          eza
          screenfetch
        ];

        programs.direnv.enable = true;
        services.gpg-agent = {
          enable = true;
          pinentryFlavor = "tty";
        };
      };
  };
}


