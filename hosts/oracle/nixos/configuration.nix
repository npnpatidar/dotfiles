{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    (builtins.fetchTarball {

      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-23.05/nixos-mailserver-nixos-23.05.tar.gz";
      sha256 = "sha256:1ngil2shzkf61qxiqw11awyl81cr7ks2kv3r3k243zz7v2xakm5c";
    })
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


  services.ollama = {
    enable = true;
  };


  environment.etc."nextcloud-admin-pass".text = "Naresh^111";
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28;
    hostName = "nextcloud.naresh.world";
    https = true;
    config = {
      adminpassFile = "/etc/nextcloud-admin-pass";
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "letsencrypt@whatisleft.anonaddy.com";
  };




  services.nginx = {
    enable = true;
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
    virtualHosts."ollama.naresh.world" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:11434";
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
    virtualHosts."code.naresh.world" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
      };
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


  environment.etc."hashed_password".text = "$2b$05$ewRpCw9V.jxb7N6UAIcSWegXCiUFdCgMK9UPmkjT36aDIiCZ4392.";
  mailserver = {
    enable = false;
    fqdn = "mail.naresh.world";
    domains = [ "naresh.world" ];
    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "original@naresh.world" = {
        hashedPasswordFile = "/etc/hashed_password";
        aliases = [ "postmaster@naresh.world" ];
        #catchAll = [ "naresh.world" ];
      };
      #"user2@example.com" = { ... };
    };
    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";
    #    certificateDomains = [ "imap.naresh.world" "pop3.naresh.world" ];

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
    withoutConnectionToken = true;
  };






}
