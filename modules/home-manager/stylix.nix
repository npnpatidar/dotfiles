{ config, pkgs, lib, ... }:

{
  stylix = {
    image = ../home-manager/nix.png;
    polarity = "dark";
    fonts = {
      serif = {
        package = pkgs.nerdfonts;
        name = "FiraCode Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.nerdfonts;
        name = "FiraCode Nerd Font Mono";
      };
      monospace = {
        package = pkgs.nerdfonts;
        name = "FiraCode Nerd Font Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        desktop = 13;
        applications = 13;
        terminal = 14;
        popups = 12;
      };
    };
    opacity = {
      terminal = 0.90;
      applications = 0.90;
      popups = 0.50;
      desktop = 0.90;
    };
    autoEnable = true;
    targets = {
      #   alacritty.enable = true;
      #   bat.enable = true;
      #   gnome.enable = true;
      #   gtk.enable = true;
      #   vscode.enable = true;
      kitty.enable = false;
    };
  };
}
