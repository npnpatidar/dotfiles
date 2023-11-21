{ config, pkgs, plasma-manager, ... }:


{

  imports = [
    ./zsh_config/zsh_config.nix
    ./plasma-manager/plasma.nix
    ./applications/applications.nix


  ];


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
    pinentryFlavor = "qt";
  };




  home.sessionVariables = {
    # EDITOR = "emacs";
  };


  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "npnpatidar";
    userEmail = "7de6dkm1@duck.com";
  };






  programs.direnv.enable = true;
  nixpkgs.config.allowUnfree = true;


}

