{ config, pkgs, ... }:
let
  rootCodePath = "/data/openvscode-server";
in
{
  systemd.services."createCodeDirectory" = {
    script = ''
      mkdir -p ${rootCodePath}
    '';
    wantedBy = [ "multi-user.target" ];
    before = [ "podman-openvscode-server.service" ];
    serviceConfig.Type = "oneshot";
  };


  virtualisation = {
    oci-containers.containers = {
      openvscode-server = {
        image = "lscr.io/linuxserver/openvscode-server:latest";
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Asia/Kolkata";
          # CONNECTION_TOKEN = "connection";
          # CONNECTION_SECRET = "connection";
          SUDO_PASSWORD = "password";
          # SUDO_PASSWORD_HASH= 
        };
        volumes = [ "${rootCodePath}:/config" ];
        ports = [ "3035:3000" ];
        autoStart = true;
      };
    };
  };
  services.nginx = {
    virtualHosts."test1.${config.globals.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3035";
        proxyWebsockets = true;
      };
    };
  };

}
