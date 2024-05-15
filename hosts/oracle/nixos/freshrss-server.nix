{ config, ... }: {
  services.freshrss = {
    enable = true;
    baseUrl = "https://freshrss.naresh.world";
    defaultUser = "naresh";
    passwordFile = config.age.secrets."standard".path;
    virtualHost = "freshrss.naresh.world";
  };

  server.nginx = {
    virtualHosts."freshrss.naresh.world" = {
      enableACME = true;
      forceSSL = true;
    };
  };
}
