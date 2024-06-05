{ ... }: {
  nixpkgs.config.allowUnfree = true;
  services.n8n.enable = true;
  services.nginx = {
    virtualHosts."n8n.naresh.world" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:5678";
      };
    };
  };
}
