{ config, lib, pkgs, inputs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "23.05"; # Did you read the comment?
  nix = {
    extraOptions = "experimental-features = nix-command flakes";
  };
  imports =
    [
      ./desktop_config/gnome_config.nix
      ./hardware-configuration.nix
    ];
  services.xserver = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
  };

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
  environment.systemPackages = with pkgs;[
    kitty
  ];
  services.dbus.enable = true;
}
