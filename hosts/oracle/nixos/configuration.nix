{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../../modules/nixos/ollama.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "alma";
  networking.domain = "";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [ ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8pK+/SUI3dPB1tQ0nF4Gp9BKKGMHnJ1bBSiYJX2sCHgbfOmDKAlAnuRTP6Zhp6BTZ5LwNC/4pI76bnpmo8YjjGNGkPlMHfOHrn8rm2Hhyx7RVHyMLGKYQdNtzBcfPgDUqrXPM3cdCMya15BnavXE4fOYUoGgIvOolTveWfngHRjQNptTlfpQoIjMRIvIfhu+xLiikJVm4EbgzEVu6U8OdGuV8eq33GYc+HORqKRq+jILIT5V3q4OTcCbORbStt4Zq4WumoVWXuM3abmzpA0nCAbZM8ArWQ8UujOM490hyQVGqfZae8FS1ADGAyEybrHMIMxT0IysZ7xW+tnaljIpt ssh-key-2024-04-15'' ];
  system.stateVersion = "23.11";
  nixpkgs.hostPlatform = "aarch64-linux";
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
  time.timeZone = "Asia/Kolkata";

  users.users.naresh = {
    isNormalUser = true;
    initialPassword = "naresh";
    description = "naresh";
    extraGroups = [ "networkmanager" "wheel" "kvm" "input" "disk" "libvirtd" "usbmux" "freshrss" "nextcloud" "openvscode-server" ];
    createHome = true;
    home = "/home/naresh";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8pK+/SUI3dPB1tQ0nF4Gp9BKKGMHnJ1bBSiYJX2sCHgbfOmDKAlAnuRTP6Zhp6BTZ5LwNC/4pI76bnpmo8YjjGNGkPlMHfOHrn8rm2Hhyx7RVHyMLGKYQdNtzBcfPgDUqrXPM3cdCMya15BnavXE4fOYUoGgIvOolTveWfngHRjQNptTlfpQoIjMRIvIfhu+xLiikJVm4EbgzEVu6U8OdGuV8eq33GYc+HORqKRq+jILIT5V3q4OTcCbORbStt4Zq4WumoVWXuM3abmzpA0nCAbZM8ArWQ8UujOM490hyQVGqfZae8FS1ADGAyEybrHMIMxT0IysZ7xW+tnaljIpt ssh-key-2024-04-15'' ];
  };

  environment.etc."nextcloud-admin-pass".text = "Naresh^111";
  networking.firewall.allowedTCPPorts = [ 80 443 11434 ];

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28;
    hostName = "nextcloud.naresh.world";
    https = true;
    config = {
      adminpassFile = "/etc/nextcloud-admin-pass";
    };
  };

  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://vaultwarden.naresh.world";
      SIGNUPS_ALLOWED = true;
      ROCKET_PORT = 8222;
      rocketAddress = "127.0.0.1";
      rocketLog = "critical";
      disableIconDownload = false;
    };
  };

  services.freshrss = {
    enable = true;
    baseUrl = "https://freshrss.naresh.world";
    defaultUser = "naresh";
    passwordFile = "/etc/nextcloud-admin-pass";
    virtualHost = "freshrss.naresh.world";
  };

  services.anki-sync-server =
    {
      enable = true;
      openFirewall = true;
      address = "127.0.0.1";
      port = 27701;
      users = [
        {
          username = "naresh";
          passwordFile = "/etc/nextcloud-admin-pass";
        }
      ];
    };

  services.openvscode-server = {
    enable = true;
    host = "127.0.0.1";
    port = 3000;
    telemetryLevel = "off";
    withoutConnectionToken = true;
  };
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    listenPort = 8888;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "letsencrypt@whatisleft.anonaddy.com";
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;

    virtualHosts."nextcloud.naresh.world" = {
      forceSSL = true;
      enableACME = true;
    };
    virtualHosts."vaultwarden.naresh.world" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8222";
      };
    };
    virtualHosts."freshrss.naresh.world" = {
      enableACME = true;
      forceSSL = true;
    };
    virtualHosts."anki.naresh.world" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:27701";
      };
    };
    virtualHosts."home.naresh.world" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8888";
      };
    };
    virtualHosts."code.naresh.world" = {
      enableACME = true;
      forceSSL = true;
      basicAuth = {
        naresh = "Naresh^111";
      };
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
      };
    };
  };

























































}
