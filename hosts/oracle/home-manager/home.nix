# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs
, lib
, config
, pkgs
, ...
}: {
  # You can import other home-manager modules here
  imports = [
    ../../../modules/home-manager/zsh/zsh.nix
    ../../../modules/home-manager/bash.nix
    ../../../modules/home-manager/git.nix
    ../../../modules/home-manager/neovim.nix
    ../../../modules/home-manager/yazi.nix
    ../../../modules/home-manager/ranger.nix
    ../../../modules/home-manager/bat.nix
    ../../../modules/nixos/globals.nix
    ./rclone.nix
  ];

  modules.home-manager = {
    bat.enable = true;
    zsh.enable = true;
    bash.enable = true;
    git.enable = true;
    neovim.enable = true;
    ranger.enable = true;
    yazi.enable = true;
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "${config.globals.default_user}";
    homeDirectory = "${config.globals.home_directory}";
  };



  programs.gpg = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };
  home.sessionVariables = {
    EDITOR = "nvim";
    #    BROWSER = "librewolf";
    #   TERMINAL = "kitty";
  };


  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    git-lfs
    curl
    screen
    jq
    nil #  nix LSP
    ripgrep #recursive search fs for a regex
    zip
    unrar
    podman-tui
    rclone
    unzip
    w3m
    oterm
    thttpd
    lazygit
    ghq
    btop
    cht-sh
    zellij
    links2
    boxbuddy
    ncdu
    mc
    onefetch
    yank
    gcc
    zig
    unzip
    fd
    tree-sitter
    comma
    fontconfig
    zlib
    # rnix-lsp
    fastfetch
    git
    git-crypt
    gnupg
    pinentry-tty
    wget
    p7zip
    fuse-7z-ng
    zoxide
    conda
    yazi
    docker
    docker-compose
    podman
    direnv
    any-nix-shell
    nixpkgs-fmt
    nixfmt-classic
    ttop
    glances
    nix-init
    ripgrep
    distrobox
    wl-clipboard
    fzf
    cargo
    # nodejs_21
    gnumake
    tldr
    curl
    tmux
    python312Packages.pudb
    python312Full
    gpg-tui
    termdbms
    bitwarden-cli
    lazydocker
    glow
    openssl
    russ
    tuifeed
    systemctl-tui
    newsboat # RSS Reader TUI
    gorilla-cli
    trashy
    cheat
    ouch
    bandwhich
    entr # run arbitrary command when file changes
    busybox
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;
  programs.zellij = {
    # enableZshIntegration = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
