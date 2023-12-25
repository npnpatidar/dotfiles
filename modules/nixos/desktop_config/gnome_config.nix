{ config, pkgs, lib, ... }:
{
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.gnome = {
    core-utilities.enable = false;
    core-developer-tools.enable = false;
    games.enable = false;
    sushi.enable = true;
    gnome-keyring.enable = true;

  };

  programs = {
    dconf.enable = true;
    file-roller.enable = true;
    seahorse.enable = true;

  };
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];


  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
  environment.systemPackages = (with pkgs;[
    nordic
    papirus-nord
    dconf2nix
  ]) ++ (with pkgs.gnome;[
    adwaita-icon-theme
    nautilus
    gnome-tweaks
    dconf-editor
    gnome-control-center
    gnome-shell-extensions
    seahorse


  ]) ++ (with pkgs.gnomeExtensions;[
    appindicator
    dash-to-panel
    blur-my-shell
    net-speed-simplified
    user-themes
    pano
    arcmenu
    custom-hot-corners-extended
    gsconnect
    panel-date-format
    # prime-helper
    # gpu-profile-selector

  ]);




}
