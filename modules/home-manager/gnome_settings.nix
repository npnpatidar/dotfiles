{ config, pkgs, ... }:

{
  gtk = {
    enable = true;

  };
  # dconf.nix is created by command: 
  #dconf dump / | dconf2nix > ~/dotfiles/modules/home-manager/dconf.nix
  imports = [ ./dconf.nix ];



  # home.packages = (with pkgs;[
  #   nordic
  # ]) ++ (with pkgs.gnome;[
  #   adwaita-icon-theme
  #   nautilus
  #   gnome-tweaks
  #   dconf-editor
  #   gnome-control-center
  #   gnome-shell-extensions
  #   seahorse
  #
  #
  # ]) ++ (with pkgs.gnomeExtensions;[
  #   appindicator
  #   dash-to-panel
  #   blur-my-shell
  #   net-speed-simplified
  #   user-themes
  #   pano
  # ]);
  #




}
