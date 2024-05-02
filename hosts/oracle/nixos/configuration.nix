{ config, pkgs, inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../../modules/nixos/ollama.nix
    ../../../modules/nixos/gitdaemon.nix
    ../../../modules/nixos/filebrowser.nix
    ../../../modules/nixos/agenix.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "alma";
  networking.domain = "";
  services.openssh.enable = true;
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
    extraGroups = [ "networkmanager" "wheel" "kvm" "input" "disk" "libvirtd" "usbmux" "freshrss" "nextcloud" "openvscode-server" "nginx" ];
    createHome = true;
    home = "/home/naresh";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8pK+/SUI3dPB1tQ0nF4Gp9BKKGMHnJ1bBSiYJX2sCHgbfOmDKAlAnuRTP6Zhp6BTZ5LwNC/4pI76bnpmo8YjjGNGkPlMHfOHrn8rm2Hhyx7RVHyMLGKYQdNtzBcfPgDUqrXPM3cdCMya15BnavXE4fOYUoGgIvOolTveWfngHRjQNptTlfpQoIjMRIvIfhu+xLiikJVm4EbgzEVu6U8OdGuV8eq33GYc+HORqKRq+jILIT5V3q4OTcCbORbStt4Zq4WumoVWXuM3abmzpA0nCAbZM8ArWQ8UujOM490hyQVGqfZae8FS1ADGAyEybrHMIMxT0IysZ7xW+tnaljIpt ssh-key-2024-04-15'' ];
    hashedPasswordFile = config.age.secrets."hashedstandard".path;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 11434 ];


  age.secrets.nextcloud_admin_password = {
    file = ../../../secrets/nextcloud_admin_password.age;
    mode = "770";
    owner = "nextcloud";
    group = "nextcloud";
  };


  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28;
    hostName = "nextcloud.naresh.world";
    https = true;
    config = {
      adminpassFile = config.age.secrets."nextcloud_admin_password".path;
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
    passwordFile = config.age.secrets."standard".path;
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
          passwordFile = config.age.secrets."standard".path;
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
    listenPort = 8888;
    services =
      [
        {
          "Services" = [
            {
              "Nextcloud" = {
                description = "Nextcloud";
                href = "http://nextcloud.naresh.world";
              };
              "Freshrss" = {
                description = "Freshrss";
                href = "http://freshrss.naresh.world";
              };
              "Ollama" = {
                description = "Ollama";
                href = "http://ollama.naresh.world";
              };
              "Chat" = {
                description = "Chat";
                href = "http://chat.naresh.world";
              };
              "VaultWarden" = {
                description = "VaultWarden";
                href = "http://vaultwarden.naresh.world";
              };
            }
          ];
        }
      ];
    bookmarks = [
      {
        Developer = [
          {
            Nix = [
              {
                abbr = "Nix";
                href = "https://search.nixos.org/options?channel=unstable";
              }
            ];
            Github = [
              {
                abbr = "Git";
                href = "https://github.com/";
              }
            ];
          }
        ];
      }
      {
        Work = [
          {
            Shaladarpan = [
              {
                abbr = "SD";
                href = "https://rajshaladarpan.nic.in/";
              }
            ];
          }
        ];
      }
    ];
    widgets = [
      {
        resources = {
          cpu = true;
          memory = true;
          disk = "/";
          uptime = true;
          units = "metric";
          refresh = 3000;
          diskUnits = "bytes";

        };
      }
      {
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
    ];
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "letsencrypt@whatisleft.anonaddy.com";
  };

  services.paperless = {
    enable = true;
    passwordFile = config.age.secrets."standard".path;
    settings = {
      PAPERLESS_ACCOUNT_ALLOW_SIGNUPS = false;
      PAPERLESS_OCR_LANGUAGE = "hin+eng+san";
      PAPERLESS_OCR_SKIP_ARCHIVE_FILE = "always";
      PAPERLESS_TIME_ZONE = config.time.timeZone;
      PAPERLESS_THREADS_PER_WORKER = 4;
    };
  };

  age.secrets.htpasswdstandard = {
    file = ../../../secrets/htpasswdstandard.age;
    mode = "770";
    owner = "nginx";
    group = "nginx";
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
    virtualHosts."paperless.naresh.world" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:28981";
      };
      extraConfig = ''
        client_max_body_size 0;
      '';
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
      basicAuthFile = config.age.secrets."htpasswdstandard".path;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
      };
    };
  };

























































}
