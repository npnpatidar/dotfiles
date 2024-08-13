{ pkgs, config, ... }:

let
  downloadsPath = "/data/Downloads";
in
{
  systemd.services."createCouchDBFolder" = {
    script = ''
      mkdir -p ${downloadsPath}
    '';
    wantedBy = [ "multi-user.target" ];
    before = [ "aria2.service" ];
    serviceConfig.Type = "oneshot";
  };



  services.aria2 = {
    enable = true;
    rpcSecretFile = config.age.secrets.standard.path;
    settings.dir = "${downloadsPath}";
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
