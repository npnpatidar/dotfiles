{ config, ... }: {
  services.openvscode-server = {
    enable = true;
    host = "127.0.0.1";
    port = 3000;
    telemetryLevel = "off";
    withoutConnectionToken = true;
  };


  age.secrets.vscode_htpassword = {
    file = ../../../secrets/vscode_htpassword.age;
    mode = "770";
    owner = "nginx";
    group = "nginx";
  };
  services.nginx = {
    virtualHosts."code.naresh.world" = {
      enableACME = true;
      forceSSL = true;
      basicAuthFile = config.age.secrets.vscode_htpassword.path;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
      };
    };
  };
}
