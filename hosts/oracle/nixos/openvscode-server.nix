{ config, pkgs }: {
  services.openvscode-server = {
    enable = true;
    host = "127.0.0.1";
    port = 3000;
    telemetryLevel = "off";
    withoutConnectionToken = true;
  };
  services.nginx = {
    virtualHosts."code.naresh.world" = {
      enableACME = true;
      forceSSL = true;
      basicAuthFile = config.age.secrets."htpasswdstandard".path;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
      };
    };
  };
}
