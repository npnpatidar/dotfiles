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
    settings = {
      background_opacity = "0.95";
      copy_on_select = true;
    };

  };


  programs.mcfly = {
    enable = true;

    enableZshIntegration = true;
    enableBashIntegration = true;
    fuzzySearchFactor = 3;
    keyScheme = "vim";
  };
}



