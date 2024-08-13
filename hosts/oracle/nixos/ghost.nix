let
  dbuser = "root";
  dbpass = "ghostpass";

  ghostDirectory = "/data/ghost";
  ghostContentDirectory = "${ghostDirectory}/content";
  ghostDatabaseDirectory = "${ghostDirectory}/database";

in
{ pkgs, config, ... }:
{
  systemd.services."createGhostDirectory" = {
    script = ''
      mkdir -p ${ghostDatabaseDirectory}
      mkdir -p ${ghostContentDirectory}
    '';
    wantedBy = [ "multi-user.target" ];
    before = [ "podman-ghost.service" "podman-ghost-db.service" ];
    serviceConfig.Type = "oneshot";
  };


  services.nginx.virtualHosts."${config.globals.domain_name}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:2368";
    };
  };

  virtualisation.oci-containers.containers.ghost = {
    hostname = "ghost";
    image = "docker.io/library/ghost:alpine";
    autoStart = true;
    ports = [ "127.0.0.1:2368:2368" ];
    volumes = [
      "${ghostContentDirectory}:/var/lib/ghost/content"
    ];
    environment = {
      url = "https://${config.globals.domain_name}";
      database__client = "mysql";
      database__connection__host = "ghost-db";
      database__connection__user = dbuser;
      database__connection__password = dbpass;
      database__connection__database = "ghost";
    };
    extraOptions = [ "--cap-add=NET_RAW" ];
  };

  virtualisation.oci-containers.containers.ghost-db = {
    hostname = "ghost-db";
    image = "docker.io/library/mariadb";
    autoStart = true;
    volumes = [ "${ghostDatabaseDirectory}:/var/lib/mysql" ];
    environment = {
      MARIADB_ROOT_PASSWORD = dbpass;
    };
  };
}

