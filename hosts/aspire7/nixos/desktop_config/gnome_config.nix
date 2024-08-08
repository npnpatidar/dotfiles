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
    adwaita-icon-theme
    nautilus
    gnome-tweaks
    dconf-editor
    seahorse
    gnome-calculator
  ]) ++ (with pkgs.gnome;[
    gnome-control-center
    gnome-shell-extensions


  ]) ++ (with pkgs.gnomeExtensions;[
    appindicator
    dash-to-panel
    dash-to-dock
    blur-my-shell
    net-speed-simplified
    user-themes
    pano
    arcmenu
    custom-hot-corners-extended
    gsconnect
    panel-date-format
    noannoyance-fork
    # syncthing-indicator
    miniview
    # topicons-plus
    # top-bar-organizer
    # prime-helper
    # gpu-profile-selector
    lock-keys
    tiling-assistant # 'tiling-assistant@leleat-on-github'
    # forge    # "forge@jmmaranan.com"
    # pop-shell #pop-shell@system76.com
    gtk4-desktop-icons-ng-ding #'gtk4-ding@smedius.gitlab.com
    # astra-monitor
    bluetooth-quick-connect
  ]);




}
