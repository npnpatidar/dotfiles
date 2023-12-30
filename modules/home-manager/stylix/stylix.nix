{ config, pkgs, lib, ... }:
{
  stylix = {
    # image = ./nix.png;

    image =
      (
        pkgs.fetchFromGitHub
          {
            owner = "NixOS";
            repo = "nixos-artwork";
            rev = "e3a74d1c40086393f2b1b9f218497da2db0ff3ae";
            sha256 = "sha256-9MRBDosbxEXNUWRimzBcyfmYtSQ/2GAliYUqA8A8GkY=";
            sparseCheckout = [ "wallpapers" ];
          } + "/wallpapers" + "/nix-wallpaper-dracula.png"
      );

    base16Scheme =
      (
        pkgs.fetchFromGitHub
          {
            owner = "tinted-theming";
            repo = "base16-schemes";
            rev = "2b6f2d0677216ddda50c9cabd6ee70fae4665f81";
            sha256 = "sha256-VTczZi1C4WSzejpTFbneMonAdarRLtDnFehVxWs6ad0=";
          } + "/ocean.yaml"
      );




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
      terminal = 0.97;
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
