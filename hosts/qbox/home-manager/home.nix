{ config, inputs, pkgs, ... }:
{
  imports = [
  ];

  home = {
    username = "naresh";
    homeDirectory = "/home/naresh";
    stateVersion = "23.05";
  };
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

























}

