{ config, lib, pkgs, ... }:

{
  # systemd.services.create-shlink-network = with config.virtualisation.oci-containers; {
  #   serviceConfig.Type = "oneshot";
  #   wantedBy = [
  #     "${backend}-shlink.service"
  #     "${backend}-shlink-web-client.service"
  #   ];
  #   script = ''
  #     ${pkgs.podman}/bin/podman network exists shlink-network || \
  #     ${pkgs.podman}/bin/podman network create shlink-network
  #   '';
  # };
  virtualisation.oci-containers.containers = {
    "shlink" = {
      image = "shlinkio/shlink:stable";
      environment = {
        DEFAULT_DOMAIN = "s.naresh.world";
        IS_HTTPS_ENABLED = "true";
        GEOLITE_LICENSE_KEY = "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";
      };
      ports = [ "6272:8080" ];
      # extraOptions = [ "--network=shlink-network" ];
    };

    "shlink-web-client" = {
      image = "shlinkio/shlink-web-client";
      environment = {
        SHLINK_SERVER_URL = "https://s.naresh.world";
        # create api link manually by sudo podman exec -it shlink shlink api-key:generate
        SHLINK_SERVER_API_KEY = "ee242192-f35f-42d4-b895-78c00f1dfb20";
      };
      ports = [ "127.0.0.1:6274:8080" ];
      # extraOptions = [ "--network=shlink-network" ];
    };
  };
  services.nginx.virtualHosts = {
    "s.naresh.world" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://127.0.0.1:6272";
    };
    "sh.naresh.world" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://127.0.0.1:6274";
    };
  };
}
