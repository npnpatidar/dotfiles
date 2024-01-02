{ config, inputs, ... }:
{
  imports = [
    ../../../modules/home-manager/kitty.nix
    ../../../modules/home-manager/vscode.nix
    ../../../modules/home-manager/zsh/zsh.nix
    ../../../modules/home-manager/librewolf.nix
    ../../../modules/home-manager/gnome_settings.nix
    ../../../modules/home-manager/neovim.nix
    #../../../modules/home-manager/nvim
    ../../../modules/home-manager/ranger.nix
    ../../../modules/home-manager/git.nix
    ../../../modules/home-manager/bat.nix
    ../../../modules/home-manager/applications.nix
    ../../../modules/home-manager/geary.nix
    ../../../modules/home-manager/xdg.nix
    ../../../modules/home-manager/masterpdfeditor.nix
    ../../../modules/home-manager/cryptomator.nix
    ../../../modules/home-manager/stylix/stylix.nix
    ../../../modules/home-manager/latex.nix
    ../../../modules/home-manager/fcitx5/fcitx5.nix
  ];

  modules.home-manager.bat.enable = true;
  nixpkgs = {
    overlays =
      # builtins.attrValues outputs.overlays
      # ++
      [
        inputs.nixneovimplugins.overlays.default
        inputs.nur.overlay
        # inputs.attic.overlays.default
        inputs.neovim-nightly-overlay.overlay
        # inputs.nixgl.overlay
        inputs.codeium.overlays."x86_64-linux".default
      ];
  };
  home = {
    username = "naresh";
    homeDirectory = "/home/naresh";
    stateVersion = "23.05";
  }; # Just don't change 

  programs.gpg = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "gnome3";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "librewolf";
    TERMINAL = "kitty";
  };

  programs.home-manager.enable = true;

  programs.direnv.enable = true;
  nixpkgs.config.allowUnfree = true;
  programs.nix-index.enable = true;



























}

