{ config, ... }: {
  services.anki-sync-server = {
    enable = true;
    openFirewall = true;
    address = "127.0.0.1";
    port = 27701;
    users = [
      {
        username = "naresh";
        passwordFile = config.age.secrets."standard".path;
      }
    ];
  };
  services.nginx = {
    virtualHosts."anki.naresh.world" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:27701";
      };
    };
  };
}
