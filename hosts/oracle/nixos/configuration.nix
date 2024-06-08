{ config, pkgs, inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./anki-server.nix
    # ./mail-server.nix
    ./nginx-server.nix
    ./ollama-server.nix
    ./rclone-backup.nix
    ./openssh-server.nix
    ./freshrss-server.nix
    ./gitdaemon-server.nix
    ./nextcloud-server.nix
    ./filebrowser-server.nix
    ./homgepage-dashboard.nix
    ./openvscode-server.nix
    ./paperless-server.nix
    ./syncthing-server.nix
    ./vaultwarden-server.nix
    ./stirling-server.nix
    ./searx.nix
    ./blog.nix
    ./ghost.nix
    ./n8n.nix
    ./invidious.nix
    ./immich.nix

    ../../../modules/nixos/agenix.nix
    ../../../modules/nixos/tailscale.nix
    ../../../modules/nixos/ssh_client.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "alma";
  networking.domain = "";
  users.users.root.openssh.authorizedKeys.keys = [ ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8pK+/SUI3dPB1tQ0nF4Gp9BKKGMHnJ1bBSiYJX2sCHgbfOmDKAlAnuRTP6Zhp6BTZ5LwNC/4pI76bnpmo8YjjGNGkPlMHfOHrn8rm2Hhyx7RVHyMLGKYQdNtzBcfPgDUqrXPM3cdCMya15BnavXE4fOYUoGgIvOolTveWfngHRjQNptTlfpQoIjMRIvIfhu+xLiikJVm4EbgzEVu6U8OdGuV8eq33GYc+HORqKRq+jILIT5V3q4OTcCbORbStt4Zq4WumoVWXuM3abmzpA0nCAbZM8ArWQ8UujOM490hyQVGqfZae8FS1ADGAyEybrHMIMxT0IysZ7xW+tnaljIpt ssh-key-2024-04-15'' ];
  system.stateVersion = "23.11";
  nixpkgs.hostPlatform = "aarch64-linux";
  nix.optimise.automatic = true;
  nix.optimise.dates = [ "03:45" ];
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
    settings.auto-optimise-store = true;
    gc = {
      automatic = false;
      dates = "weekly";
      options = "--delete-older-than 3d";
    };
  };

  programs.zsh = {
    enable = true;
  };

  environment.systemPackages = [ inputs.agenix.packages.aarch64-linux.default ];
  time.timeZone = "Asia/Kolkata";

  users.users.naresh = {
    isNormalUser = true;
    description = "naresh";
    extraGroups = [ "networkmanager" "wheel" "kvm" "input" "disk" "libvirtd" "usbmux" "freshrss" "nextcloud" "openvscode-server" "nginx" "syncthing" ];
    createHome = true;
    home = "/home/naresh";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8pK+/SUI3dPB1tQ0nF4Gp9BKKGMHnJ1bBSiYJX2sCHgbfOmDKAlAnuRTP6Zhp6BTZ5LwNC/4pI76bnpmo8YjjGNGkPlMHfOHrn8rm2Hhyx7RVHyMLGKYQdNtzBcfPgDUqrXPM3cdCMya15BnavXE4fOYUoGgIvOolTveWfngHRjQNptTlfpQoIjMRIvIfhu+xLiikJVm4EbgzEVu6U8OdGuV8eq33GYc+HORqKRq+jILIT5V3q4OTcCbORbStt4Zq4WumoVWXuM3abmzpA0nCAbZM8ArWQ8UujOM490hyQVGqfZae8FS1ADGAyEybrHMIMxT0IysZ7xW+tnaljIpt ssh-key-2024-04-15'' ];
    hashedPasswordFile = config.age.secrets."hashedstandard".path;
  };

  networking.firewall.allowedTCPPorts = [ 443 80 ];
  # networking.firewall.allowedUDPPorts = [ 22000 21027 ];

  virtualisation.oci-containers.backend = "podman";

  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true;
    autoPrune.enable = true;
  };
}
