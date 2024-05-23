{ config, lib, pkgs, inputs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  # Update nixos
  # system.autoUpgrade = {
  #   #		enable = true;
  #   allowReboot = false;
  #   channel = "https://channels.nixos.org/nixos-unstable";
  # };

  system.stateVersion = "23.05"; # Did you read the comment?


  nix = {

    # package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
    # settings.auto-optimise-store = true;
    # gc = {
    #   automatic = false;
    #   dates = "weekly";
    #   options = "--delete-older-than 3d";
    # };
  };




  imports =
    [
      #  "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
      # ./aspire7_disko.nix
      ./desktop_config/gnome_config.nix
      # ./nvidia.nix
      # ./syncthing.nix
      # ./dns_config.nix
      # ./docker.nix
      # ./ssh.nix
      # ./virtualisation.nix
      # ./bootloader.nix
      # ./networking.nix
      # ./power_management.nix
      # ./sound.nix
      # ./input.nix
      # ./nix_related.nix
      # ./apple.nix
      # ./fingerprint.nix
      # ./fonts.nix
      # ./ollama_local.nix
      # ../../../modules/nixos/servarr.nix
      ./hardware-configuration.nix
      # ../../../modules/nixos/agenix.nix
      # ../../../modules/nixos/tailscale.nix
      # ../../../modules/nixos/ssh_client.nix

    ];


  # programs.geary.enable = true;

  services.xserver = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  networking = {
    hostName = "qbox";
    networkmanager.enable = true;
  };

  # Bluetooth
  # hardware.bluetooth.enable = true; # enables support for Bluetooth
  # hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.naresh = {
    isNormalUser = true;
    description = "naresh";
    extraGroups = [ "networkmanager" "wheel" "kvm" "input" "disk" "libvirtd" "usbmux" ];
    createHome = true;
    home = "/home/naresh";
    shell = pkgs.zsh;
    initialPassword = "naresh";
    # hashedPasswordFile = config.age.secrets."hashedstandard".path;
  };

  environment.systemPackages = [
    # inputs.agenix.packages.x86_64-linux.default
    # pkgs.gparted
  ];
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

  # services.flatpak.enable = true;
  services.dbus.enable = true;
  # services.printing.enable = true;

  # programs.steam.enable = true;


}
