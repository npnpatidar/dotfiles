{ pkgs, config, ... }:
{
  services.aria2 = {
    enable = true;
    rpcSecretFile = config.age.secrets.standard.path;
  };
  services.nginx.virtualHosts."aria.naresh.world" = {
    enableACME = true;
    forceSSL = true;
    locations."/jsonrpc" = {
      proxyPass = "http://127.0.0.1:6800";
      proxyWebsockets = true;
    };
  };
  users.groups."aria2" = {
    members = [ "naresh" "jellyfin" ];
  };
}
