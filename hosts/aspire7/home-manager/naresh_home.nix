{ config, inputs, pkgs, ... }:
{
  imports = [
    ../../../modules/home-manager
    ../../../modules/nixos/globals.nix
  ];

  modules.home-manager = {
    bat.enable = true;
    qutebrowser.enable = false;
    zsh.enable = true;
    bash.enable = true;
    fcitx5.enable = true;
    stylix.enable = true;
    cryptomator.enable = true;
    geary.enable = true;
    git.enable = true;
    kitty.enable = true;
    latex.enable = false;
    librewolf.enable = true;
    masterpdfeditor.enable = true;
    neovim.enable = true;
    ranger.enable = true;
    vscode.enable = true;
    xdg.enable = true;
    tmux.enable = false;
    yazi.enable = true;
    zathura.enable = false;
    sioyek.enable = true;
    joplin.enable = true;
    mpv.enable = true;
    imv.enable = true;
    newsboat.enable = true;
  };
  nixpkgs = {
    overlays =
      # builtins.attrValues outputs.overlays
      # ++
      [
        # inputs.nixneovimplugins.overlays.default
        # inputs.nur.overlay
        # inputs.attic.overlays.default
        # inputs.neovim-nightly-overlay.overlay
        # inputs.nixgl.overlay
        # inputs.codeium.overlays."x86_64-linux".default
      ];
  };
  home = {
    username = "${config.globals.default_user}";
    homeDirectory = "${config.globals.home_directory}";
    stateVersion = "23.05";
  }; # Just don't change 

  programs.gpg = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "librewolf";
    TERMINAL = "kitty";
  };

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

























}

