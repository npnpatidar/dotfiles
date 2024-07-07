{ config, pkgs, ... }: {


  services.jellyfin = {
    enable = true;
  };
  services.nginx = {

    virtualHosts."jellyfin.${config.globals.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
      };
    };
  };

}
