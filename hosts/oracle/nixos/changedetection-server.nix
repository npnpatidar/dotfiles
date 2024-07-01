{ config, lib, pkgs, ... }:
let
  datastorePath = "/var/lib/changedetection-io";
  baseURL = "change.${config.globals.domain_name}";
in
{
  services.nginx.virtualHosts."${baseURL}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:5000";
      proxyWebsockets = true;
    };
  };

  systemd.services.changedetection-io = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    preStart = ''
      mkdir -p -m 0750 ${datastorePath}
    '';
    serviceConfig = {
      User = "changedetection-io";
      Group = "changedetection-io";
      StateDirectory = "changedetection-io";
      StateDirectoryMode = "0750";
      WorkingDirectory = datastorePath;
      Environment = [
        "HIDE_REFERER=false"
        "BASE_URL=${baseURL}"
        "USE_X_SETTINGS=1"
        "WEBDRIVER_URL=http://127.0.0.1:4444/wd/hub"
        "PLAYWRIGHT_DRIVER_URL=ws://127.0.0.1:4455/?stealth=1&--disable-web-security=true"
      ];
      ExecStart = ''
        ${pkgs.changedetection-io}/bin/changedetection.py \
          -h localhost -p 5000 -d ${datastorePath}
      '';
      ProtectHome = true;
      ProtectSystem = true;
      Restart = "on-failure";
    };
  };

  users = {
    users = {
      "changedetection-io" = {
        isSystemUser = true;
        group = "changedetection-io";
      };
    };

    groups = {
      "changedetection-io" = { };
    };
  };

  virtualisation = {
    oci-containers.containers = {
      changedetection-io-webdriver = {
        image = "selenium/standalone-chromium";
        environment = {
          VNC_NO_PASSWORD = "1";
          SCREEN_WIDTH = "1920";
          SCREEN_HEIGHT = "1080";
          SCREEN_DEPTH = "24";
        };
        ports = [
          "127.0.0.1:4444:4444"
        ];
        volumes = [
          "/dev/shm:/dev/shm"
        ];
      };
      changedetection-io-playwright = {
        image = "browserless/chrome";
        environment = {
          SCREEN_WIDTH = "1920";
          SCREEN_HEIGHT = "1024";
          SCREEN_DEPTH = "16";
          ENABLE_DEBUGGER = "false";
          PREBOOT_CHROME = "true";
          CONNECTION_TIMEOUT = "300000";
          MAX_CONCURRENT_SESSIONS = "10";
          CHROME_REFRESH_TIME = "600000";
          DEFAULT_BLOCK_ADS = "true";
          DEFAULT_STEALTH = "true";
        };
        ports = [
          "127.0.0.1:4455:3000"
        ];
      };
    };
  };
}
