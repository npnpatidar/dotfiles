{ config, lib, pkgs, inputs, ... }:
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
      ./desktop_config/gnome_config.nix
      ./nvidia.nix
      ./syncthing.nix
      ./dns_config.nix
      ./docker.nix
      ./ssh.nix
      ./virtualisation.nix
      ./bootloader.nix
      ./networking.nix
      ./power_management.nix
      ./sound.nix
      ./input.nix
      ./nix_related.nix
      ./apple.nix
      ./fonts.nix
      # ./fingerprint.nix

      # ../../../modules/nixos/servarr.nix
      ./hardware-configuration.nix
      ../../../modules/nixos/agenix.nix
      ../../../modules/nixos/tailscale.nix
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
    description = "naresh";
    extraGroups = [ "networkmanager" "wheel" "kvm" "input" "disk" "libvirtd" "usbmux" ];
    createHome = true;
    home = "/home/naresh";
    shell = pkgs.zsh;
    hashedPasswordFile = config.age.secrets."hashedstandard".path;
  };

  environment.systemPackages = [
    inputs.agenix.packages.x86_64-linux.default
    pkgs.gparted
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

  # enable flatpak support
  services.flatpak.enable = true;
  services.dbus.enable = true;

  # programs.steam.enable = true;


  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };

  virtualisation = {
    oci-containers = {
      containers = {
        open-webui = {
          image = "ghcr.io/open-webui/open-webui:main";
          autoStart = true;
          ports = [
            "127.0.0.1:8080:8080"
          ];
          volumes = [
            "open-webui:/app/backend/data"
          ];
          environment = {
            OLLAMA_BASE_URL = "http://127.0.0.1:11434";
            ANONYMIZED_TELEMETRY = "False";
          };
          extraOptions = [
            "--network=host"
            "--add-host=host.containers.internal:host-gateway"
          ];
        };
      };
    };
  };

}
