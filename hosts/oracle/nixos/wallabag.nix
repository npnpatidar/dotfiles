{ config, lib, pkgs, ... }:
let
  domain = "wallabag.${config.globals.domain_name}";
  port = "2300";
in
{
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${port}";
    };
  };

  virtualisation.oci-containers.containers.wallabag = {
    image = "wallabag/wallabag";
    ports = [ "${port}:80/tcp" ];
    volumes = [
      "images:/var/www/wallabag/web/assets/images:rw"
    ];
    environment = {
      SYMFONY__ENV__FOSUSER_REGISTRATION = "true";
      SYMFONY__ENV__FOSUSER_CONFIRMATION = "false";
      SYMFONY__ENV__DOMAIN_NAME = "https://${domain}";
    };
  };
}

