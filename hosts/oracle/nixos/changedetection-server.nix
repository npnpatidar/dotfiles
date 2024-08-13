{ config, lib, pkgs, ... }:
let
  datastorePath = "/var/lib/changedetection-io/changedetection-io";
  webdriverDatapath = "/var/lib/changedetection-io/webdriver";
  baseURL = "change.${config.globals.domain_name}";
in
{
  systemd.services."createChangeDetectionDirectory" = {
    script = ''
      mkdir -p ${datastorePath}
      mkdir -p ${webdriverDatapath}
    '';
    wantedBy = [ "multi-user.target" ];
    before = [ "podman-changedetection-io.service" ];
    serviceConfig.Type = "oneshot";
  };


  services.nginx.virtualHosts."${baseURL}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:5000";
      proxyWebsockets = true;
    };
  };


  virtualisation = {
    oci-containers.containers = {
      changedetection-io = {
        image = "lscr.io/linuxserver/changedetection.io:latest";
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Asia/Kolkata";
          HIDE_REFERER = "false";
          BASE_URL = "${baseURL}";
          USE_X_SETTINGS = "1";
          WEBDRIVER_URL = "http://changedetection-io.local:4444/wd/hub";
          PLAYWRIGHT_DRIVER_URL = "ws://changedetection-io.local:4455/?stealth=1&--disable-web-security=true";
        };
        volumes = [ "${datastorePath}:/config" ];
        ports = [ "5000:5000" ];
        autoStart = true;
        extraOptions = [
          "--network=slirp4netns:allow_host_loopback=true"
          "--add-host=changedetection-io.local:10.0.2.2"
        ];
      };
      changedetection-io-webdriver = {
        image = "selenium/standalone-chromium";
        autoStart = true;
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
          "${webdriverDatapath}:/dev/shm"
        ];
      };

      changedetection-io-playwright = {
        image = "ghcr.io/browserless/chromium";
        autoStart = true;
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
