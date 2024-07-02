{ config, pkgs, ... }: {

  # system.activationScripts.makeJoplinDir = pkgs.lib.stringAfter [ "var" ] ''
  #   mkdir -m 750 -p /var/lib/joplin
  # '';
  virtualisation.oci-containers.containers = {
    joplin = {
      image = "florider89/joplin-server";
      ports = [ "22300:22300" ];
      volumes = [
        "joplin_data:/data"
      ];
      autoStart = true;
      environment = {
        APP_BASE_URL = "https://joplin.${config.globals.domain_name}";
        STORAGE_DRIVER = "Type=Filesystem; Path=/data";
        SQLITE_DATABASE = "/data/db.sqlite";
        MAX_TIME_DRIFT = "0";
      };
    };
  };
  services.nginx.virtualHosts."joplin.${config.globals.domain_name}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:22300";
    };
  };


}
