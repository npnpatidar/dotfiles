{ config, lib, pkgs, inputs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "23.05"; # Did you read the comment?
  nix = {
    extraOptions = "experimental-features = nix-command flakes";
  };
  imports =
    [
      # ./desktop_config/gnome_config.nix
      ./hardware-configuration.nix
    ];
  programs.zsh = {
    enable = true;
  };




  home-manager.backupFileExtension = "backup";
  hardware =
    {
      opengl.enable = true;
      nvidia.modesetting.enable = true;
    };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
  services.xserver.displayManager.gdm.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  services.xserver.enable = false;
  programs.waybar.enable = true;
  environment.systemPackages = with pkgs;[
    kitty
    rofi-wayland
    dunst
    pyprland
    hyprpicker
    hyprcursor
    hyprlock
    hypridle
    hyprpaper
    # greetd.tuigreet
    eww
    neovim
  ];

  # Enable Display Manager
  # services.greetd = {
  #   enable = true;
  #   settings = {
  #     default_session = {
  #       command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd Hyprland";
  #       user = "greeter";
  #     };
  #   };
  # };









  time.timeZone = "Asia/Kolkata";

  networking = {
    hostName = "qbox";
    networkmanager.enable = true;
  };

  users.users.naresh = {
    isNormalUser = true;
    description = "naresh";
    createHome = true;
    home = "/home/naresh";
    shell = pkgs.zsh;
    initialPassword = "naresh";
  };
  services.dbus.enable = true;
}
