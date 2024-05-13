{ pkgs, config, ... }:

{
  environment.systemPackages = [ pkgs.filebrowser ];
  #default username = "admin" and password  = "admin"
  systemd.services.filebrowser = {
    enable = true;
    wantedBy = [ "default.target" ];
    serviceConfig = {
      User = "root";
      Group = "wheel";
      ExecStart =
        "/run/current-system/sw/bin/filebrowser --database /var/lib/filebrowser/filebrowser.db --address 0.0.0.0 -p 8081";
    };
  };

  services.nginx.virtualHosts."files.naresh.world" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:8081";
    };
  };
}

