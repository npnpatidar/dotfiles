{ config, pkgs, inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../../modules/nixos/ollama.nix
    ../../../modules/nixos/gitdaemon.nix
    # ../../../modules/nixos/filebrowser.nix
    ../../../modules/nixos/agenix.nix
    ../../../modules/nixos/tailscale.nix
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
    extraGroups = [ "networkmanager" "wheel" "kvm" "input" "disk" "libvirtd" "usbmux" "freshrss" "nextcloud" "openvscode-server" "nginx" ];
    createHome = true;
    home = "/home/naresh";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8pK+/SUI3dPB1tQ0nF4Gp9BKKGMHnJ1bBSiYJX2sCHgbfOmDKAlAnuRTP6Zhp6BTZ5LwNC/4pI76bnpmo8YjjGNGkPlMHfOHrn8rm2Hhyx7RVHyMLGKYQdNtzBcfPgDUqrXPM3cdCMya15BnavXE4fOYUoGgIvOolTveWfngHRjQNptTlfpQoIjMRIvIfhu+xLiikJVm4EbgzEVu6U8OdGuV8eq33GYc+HORqKRq+jILIT5V3q4OTcCbORbStt4Zq4WumoVWXuM3abmzpA0nCAbZM8ArWQ8UujOM490hyQVGqfZae8FS1ADGAyEybrHMIMxT0IysZ7xW+tnaljIpt ssh-key-2024-04-15'' ];
    hashedPasswordFile = config.age.secrets."hashedstandard".path;
  };

  networking.firewall.allowedTCPPorts = [ 443 ];
  # networking.firewall.allowedUDPPorts = [ 22000 21027 ];

  age.secrets.nextcloud_admin_password = {
    file = ../../../secrets/nextcloud_admin_password.age;
    mode = "770";
    owner = "nextcloud";
    group = "nextcloud";
  };

  services.openssh = {
    enable = true;
    ports = [ 46587 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [ "naresh" "git" ];
    };
    extraConfig = "MaxAuthTries 10";
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
    settings = {
      title = "Naresh";
      language = "en";
      headerStyle = "boxedWidgets";
      disableCollape = true;
      favicon = "https://em-content.zobj.net/source/twitter/376/cloud_2601-fe0f.png";
      cardBlur = "md";
      theme = "dark";
      color = "gray";
      fiveColumns = true;
      statusStyle = "dot";
      hideVersion = true;
      background = {
        # image = "https://media.githubusercontent.com/media/lunik1/nix-wallpaper/assets/nord-night.png";
        # image = "https://github.com/NixOS/nixos-artwork/blob/f38303238fb03b89e29b6c8c2fd32e59df59a2d5/wallpapers/nix-wallpaper-simple-blue.png";
        # image = ../../../modules/home-manager/stylix/nix.png;
        image = "https://github.com/NixOS/nixos-artwork/blob/master/wallpapers/nix-wallpaper-gear.png?raw=true";
        # brightness = 50;
        # blur = "sm";
        # saturate = 50;
        opacity = 50;
      };
      providers = {
        # openweathermap = "{{HOMEPAGE_VAR_OPENWEATHERMAP}}";
      };
      layout = [
        {
          "Services" = {
            style = "row";
            columns = 5;
          };
        }
        {
          "Nix" = {
            style = "row";
            columns = 5;
          };
        }
        {
          "Work" = {
            style = "row";
            columns = 5;
          };
        }
      ];
    };
    services =
      [
        {
          "Services" = [
            {
              "Nextcloud" = {
                icon = "nextcloud";
                href = "http://nextcloud.naresh.world";
                # widget = {
                #   type = "nextcloud";
                #   url = "http://nextcloud.naresh.world";
                #   username = "naresh";
                #   password = "";
                # };
              };
            }
            {
              "Freshrss" = {
                icon = "freshrss";
                href = "http://freshrss.naresh.world";
              };
            }
            {
              "Ollama" = {
                icon = "https://ollama.com/public/ollama.png";
                href = "http://ollama.naresh.world";
              };
            }
            {
              "Chat" = {
                icon = "open-webui";
                href = "http://chat.naresh.world";
              };
            }
            {
              "Local Chat" = {
                icon = "open-webui";
                href = "http://localhost:8080";
              };
            }
            {
              "News" = {
                icon = "https://newsboat.org/logo.svg";
                href = "http://news.naresh.world";
              };
            }
            {
              "VaultWarden" = {
                icon = "vaultwarden";
                href = "http://vaultwarden.naresh.world";
              };
            }
            {
              "Paperless" = {
                icon = "paperless-ngx";
                href = "http://paperless.naresh.world";
              };
            }
            {
              "Files" = {
                icon = "files";
                href = "http://files.naresh.world";
              };
            }
            {
              "Code" = {
                icon = "vscode";
                href = "http://code.naresh.world";
              };
            }
            # {
            #   "NextDNS" = {
            #     icon = "nextdns";
            #     widget = {
            #       type = "nextdns";
            #       profileid = "iec4ca1";
            #       key = "";
            #     };
            #   };
            # }
          ];
        }
      ];
    bookmarks = [
      {
        Nix = [
          {
            Nixos = [
              {
                abbr = "Nix";
                href = "https://search.nixos.org/options?channel=unstable";
              }
            ];
          }
          {
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
          cputemp = true;
          disk = "/";
          uptime = true;
          units = "metric";
          refresh = 3000;
          diskUnits = "bytes";

        };
      }
      {
        search = {
          provider = [ "duckduckgo" "brave" "google" ];
          target = "_blank";
          # showSearchSuggestions = true;
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

  services = {
    syncthing = {
      enable = true;
      user = "naresh";
      openDefaultPorts = true;
      dataDir = "/home/naresh/Data/";
      configDir = "/home/naresh/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      guiAddress = "alma.tail4db3da.ts.net:8384";
      # extraFlags = [
      #   "-gui-address=alma.tail4db3da.ts.net:8384"
      # ];
      # relay.enable = true;
      settings.gui = {
        user = "naresh";
        password = "naresh";
      };
      settings.devices = {

        "RMX3312" = {
          id = "TYHX2SD-7KN5PCE-DMUV7F6-T5I22IU-5XJNC2A-JUAWJCK-M74C276-U6PNGAA";
          name = "RMX3312";
          autoAcceptFolders = true;
          addresses = [
            "tcp://realme.tail4db3da.ts.net:22000"
          ];
        };
        #
        "Ipad" = {
          id = "EYUCT6O-SQMOKM2-UWA5QAN-OVFGS3G-NNKX5RC-IBL5FLF-LD3YR55-LLMJOA4";
          name = "Ipad";
          autoAcceptFolders = true;
          addresses = [
            "tcp://ipad.tail4db3da.ts.net:22000"
          ];
        };
        "nixos" = {
          id = "OMKURTY-PGTTG6P-ZUJDTQD-FV7Z6YM-FUPIFGZ-FEDVDA2-N6C7IFR-OXAFHAM";
          name = "nixos";
          autoAcceptFolders = true;
          addresses = [
            "tcp://nixos.tail4db3da.ts.net:22000"
          ];
        };
      };

      settings.folders = {
        # "Camera" = {
        # id = "knuao-1ygcm";
        #   label = "Camera";
        #   path = "/home/naresh/Camera";
        #   devices = [ "RMX3312" ];
        # };
        # "Sync_M_L" = {
        #   id = "tpz2c-x9q93";
        #   label = "Sync_M_L";
        #   path = "/home/naresh/Data/Sync_M_L";
        #   devices = [ "RMX3312" ];
        # };
        # "Sync_M_L_I_C" = {
        #   id = "7snbs-p6fiq";
        #   label = "Sync_M_L_I_C";
        #   path = "/home/naresh/Data/Sync_M_L_I_C";
        #   devices = [ "RMX3312" "Ipad" ];
        # };
        # "Sync_M_L_I" = {
        #   id = "pwm3j-ulcds";
        #   label = "Sync_M_L_I";
        #   path = "/home/naresh/Data/Sync_M_L_I";
        #   devices = [ "RMX3312" "Ipad" ];
        # };
        "Sync_M_L_I_O" = {
          id = "y3xfw-sbf3u";
          label = "Sync_M_L_I_O";
          path = "/home/naresh/Data/Sync_M_L_I_O";
          devices = [ "RMX3312" "Ipad" "nixos" ];
        };
      };
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
    virtualHosts."ollama.naresh.world" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:11434";
      };
    };
    virtualHosts."chat.naresh.world" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8090";
      };
    };
    virtualHosts."test.naresh.world" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8384";
      };
    };

  };

























































}
