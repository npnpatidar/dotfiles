{ config, pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "FiraCode";
      size = 13;
      package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
    };
    theme = "Tokyo Night Storm";
    shellIntegration = {
      enableBashIntegration = true;
      enableZshIntegration = true;
    };


  };


  programs.mcfly = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    fuzzySearchFactor = 3;
    keyScheme = "vim";
  };
}
