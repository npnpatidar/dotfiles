{ config, pkgs, ... }:
{
  imports = [
	../../../modules/home-manager/zsh/zsh.nix
	../../../modules/home-manager/bat.nix
        ../../../modules/home-manager/bash.nix
	../../../modules/home-manager/yazi.nix
	../../../modules/home-manager/ranger.nix
	../../../modules/home-manager/git.nix
  ];

  modules.home-manager = {
    bat.enable = true;
    zsh.enable = true;
    bash.enable = true;
    git.enable = true;
    ranger.enable = true;
    yazi.enable = true;
  };
  nixpkgs = {
    overlays =
      # builtins.attrValues outputs.overlays
      # ++
      [
        # inputs.nixneovimplugins.overlays.default
        # inputs.attic.overlays.default
        # inputs.neovim-nightly-overlay.overlay
        # inputs.nixgl.overlay
        # inputs.codeium.overlays."x86_64-linux".default
      ];
  };
  home = {
    username = "ubuntu";
    homeDirectory = "/home/ubuntu";
    stateVersion = "23.11";
  }; # Just don't change 

  programs.gpg = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;


 home.packages= with pkgs;[

atuin
];






















}

