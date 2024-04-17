{ config, pkgs, lib,... }:
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
programs.nix-index = {
enable = lib.mkForce false;
};

 home.packages= with pkgs;[
zellij
cht-sh
neofetch
btop
mc
ncdu
lazygit
ripgrep

];


programs.neovim = {
    enable = true;
    plugins = with pkgs; [ vimPlugins.LazyVim ];
};


  home.file.".config/nvim".source = pkgs.fetchFromGitHub {
      owner = "LazyVim";
      repo = "starter";
      rev = "master";
#      hash = "sha256-gE2tRpglA0SxxjGN+uKwkwdR5YurvjVGf8SRKkW0E1U=";
hash = "sha256-mZbQVDh6T3GylIPvMGFV9Sp4Oc6TMiqUYW8nPATs+dE=";
    };


















}

