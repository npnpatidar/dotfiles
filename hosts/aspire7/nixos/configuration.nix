# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import builtins.fetchTarball
      {
        url = "https://github.com/nix-community/NUR/archive/master.tar.gz";
        sha256 = "sha256:0plki2yk02zcvyw7vynqhag6g1kl5qcicj8dvzfjx5p3p82yilkk";
      }
      {
        inherit pkgs;
      };
  };


  imports =
    [
      #  "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
      # ./aspire7_disko.nix
      ../../../modules/nixos/desktop_config/gnome_config.nix
      # ../../../modules/nixos/nvidia.nix
      ../../../modules/nixos/syncthing.nix
      ../../../modules/nixos/dns_config.nix
      ../../../modules/nixos/docker.nix
      ../../../modules/nixos/ssh.nix
      ../../../modules/nixos/virtualisation.nix
      ../../../modules/nixos/bootloader.nix
      ../../../modules/nixos/networking.nix
      ../../../modules/nixos/power_management.nix
      ../../../modules/nixos/sound.nix
      ../../../modules/nixos/input.nix
      ../../../modules/nixos/nix_related.nix
      ../../../modules/nixos/apple.nix
      ./hardware-configuration.nix
    ];


  # programs.geary.enable = true;


  programs.zsh = {
    enable = true;
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";


  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.naresh = {
    isNormalUser = true;
    initialPassword = "naresh";
    description = "naresh";
    extraGroups = [ "networkmanager" "wheel" "kvm" "input" "disk" "libvirtd" "usbmux" ];
    createHome = true;
    home = "/home/naresh";
    shell = pkgs.zsh;
  };


  # environment.systemPackages = [ config.nur.repos.mic92.hello-nur ];
  # environment.systemPackages = with pkgs; [
  # openssh
  #     appimage-run
  #     auto-cpufreq
  #     flatpak
  # nextdns
  # systemd
  # usbmuxd
  # usbmuxd2

  #     (import ./appimage/thorium.nix { inherit pkgs; })
  # (import ./appimage/filen-desktop.nix { inherit pkgs; })
  # ];

  # List services that you want to enable:

  # enable flatpak support
  services.flatpak.enable = true;
  services.dbus.enable = true;






}
