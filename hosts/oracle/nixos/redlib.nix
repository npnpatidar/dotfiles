{ config, pkgs, ... }: {


  services.redlib = {
    enable = true;
    port = 5767;

  };

  services.nginx = {

    virtualHosts."red.${config.globals.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:5767";
        proxyWebsockets = true;
      };
    };


  };
}
