{ config, ... }: {
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
                href = "http://nextcloud.${config.globals.domain_name}";
                # widget = {
                #   type = "nextcloud";
                #   url = "http://nextcloud.${config.globals.domain_name}";
                #   username = "naresh";
                #   password = "";
                # };
              };
            }
            {
              "Freshrss" = {
                icon = "freshrss";
                href = "http://freshrss.${config.globals.domain_name}";
              };
            }
            {
              "Ollama" = {
                icon = "https://ollama.com/public/ollama.png";
                href = "http://ollama.${config.globals.domain_name}";
              };
            }
            {
              "Chat" = {
                icon = "open-webui";
                href = "http://chat.${config.globals.domain_name}";
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
                href = "http://news.${config.globals.domain_name}";
              };
            }
            {
              "VaultWarden" = {
                icon = "vaultwarden";
                href = "http://vaultwarden.${config.globals.domain_name}";
              };
            }
            {
              "Paperless" = {
                icon = "paperless-ngx";
                href = "http://paperless.${config.globals.domain_name}";
              };
            }
            {
              "Files" = {
                icon = "files";
                href = "http://files.${config.globals.domain_name}";
              };
            }
            {
              "Code" = {
                icon = "vscode";
                href = "http://code.${config.globals.domain_name}";
              };
            }
            {
              "Syncthing" = {
                icon = "syncthing";
                href = "https://syncthing.${config.globals.domain_name}";
              };
            }
            {
              "Git" = {
                icon = "git";
                href = "https://git.${config.globals.domain_name}";
              };
            }
            {
              "Stirling-pdf" = {
                icon = "stirling-pdf";
                href = "https://stirling.${config.globals.domain_name}";
              };
            }
            {
              "Searx" = {
                icon = "searx";
                href = "https://searx.${config.globals.domain_name}";
              };
            }
            {
              "Test" = {
                # icon = "syncthing";
                href = "http://test.${config.globals.domain_name}";
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

  services.nginx = {
    virtualHosts."home.${config.globals.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8888";
      };
    };
  };
}
