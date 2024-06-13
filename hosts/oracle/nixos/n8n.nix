{ config, ... }: {
  nixpkgs.config.allowUnfree = true;
  services.n8n.enable = true;
  services.nginx = {
    virtualHosts."n8n.${config.globals.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:5678";
        proxyWebsockets = true;
      };
    };
  };
}
