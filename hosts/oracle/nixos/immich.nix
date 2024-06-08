{ config, pkgs, ... }:

let
  immichRoot = "/var/lib/immich";
  immichPhotos = "${immichRoot}/photos";
  immichAppdataRoot = "${immichRoot}/appdata";
  immichVersion = "v1.105.1";

  postgresRoot = "${immichAppdataRoot}/pgsql";
  postgresPassword = "immich";
  postgresUser = "immich";
  postgresDb = "immich";

  extraOptions = [
    "--pull=newer"
    "--network=immich-network"
  ];

  immich_environment = {
    IMMICH_VERSION = immichVersion;
    DB_HOSTNAME = "immich_postgres";
    DB_USERNAME = postgresUser;
    DB_DATABASE_NAME = postgresDb;
    DB_PASSWORD = postgresPassword;
    REDIS_HOSTNAME = "immich_redis";
  };
in
{
  networking.firewall.interfaces."podman+".allowedUDPPorts = [ 53 5353 ];

  systemd.services.create-immich-network = with config.virtualisation.oci-containers; {
    serviceConfig.Type = "oneshot";
    wantedBy = [
      "${backend}-immich_server.service"
      "${backend}-immich_microservices.service"
      "${backend}-immich_machine_learning.service"
      "${backend}-immich_redis.service"
      "${backend}-immich_postgres.service"
    ];
    script = ''
      ${pkgs.podman}/bin/podman network exists immich-network || \
      ${pkgs.podman}/bin/podman network create immich-network
    '';
  };

  # services.nginx.enable = true;
  services.nginx.virtualHosts."immich.naresh.world" = {
    extraConfig = ''
      client_max_body_size 50000M;
    '';
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:2283";
      proxyWebsockets = true;
    };
  };


  # The primary source for this configuration is the recommended docker-compose installation of immich from
  # https://immich.app/docs/install/docker-compose, which linkes to:
  # - https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml
  # - https://github.com/immich-app/immich/releases/latest/download/example.env
  # and has been transposed into nixos configuration here.  Those upstream files should be checked
  # for serious changes if there are any upgrade problems here.
  #
  # After initial deployment, these in-process configurations need to be done:
  # - create an admin user by accessing the site
  # - login with the admin user
  # - set the "Machine Learning Settings" > "URL" to http://immich_machine_learning:3003

  virtualisation.oci-containers.containers = {
    immich_server = {
      image = "ghcr.io/immich-app/immich-server:${immichVersion}";
      cmd = [ "start.sh" "immich" ];
      volumes = [
        "${immichPhotos}:/usr/src/app/upload"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = immich_environment;
      ports = [ "127.0.0.1:2283:3001" ];
      dependsOn = [
        "immich_redis"
        "immich_postgres"
      ];
      extraOptions = extraOptions;
    };

    immich_microservices = {
      image = "ghcr.io/immich-app/immich-server:${immichVersion}";
      cmd = [ "start.sh" "microservices" ];
      volumes = [
        "${immichPhotos}:/usr/src/app/upload"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = immich_environment;
      dependsOn = [
        "immich_redis"
        "immich_postgres"
      ];
      extraOptions = extraOptions;
    };

    immich_machine_learning = {
      image = "ghcr.io/immich-app/immich-machine-learning:${immichVersion}";
      volumes = [ "${immichAppdataRoot}/model-cache:/cache" ];
      environment = {
        IMMICH_VERSION = immichVersion;
      };
      extraOptions = extraOptions;
    };

    immich_redis = {
      image = "registry.hub.docker.com/library/redis:6.2-alpine@sha256:84882e87b54734154586e5f8abd4dce69fe7311315e2fc6d67c29614c8de2672";
      extraOptions = extraOptions;
    };

    immich_postgres = {
      image = "registry.hub.docker.com/tensorchord/pgvecto-rs:pg14-v0.2.0@sha256:90724186f0a3517cf6914295b5ab410db9ce23190a2d9d0b9dd6463e3fa298f0";
      volumes = [ "${postgresRoot}:/var/lib/postgresql/data" ];
      environment = {
        POSTGRES_PASSWORD = postgresPassword;
        POSTGRES_USER = postgresUser;
        POSTGRES_DB = postgresDb;
        POSTGRES_INITDB_ARGS = "--data-checksums";
      };
      extraOptions = extraOptions;
    };
  };
}

