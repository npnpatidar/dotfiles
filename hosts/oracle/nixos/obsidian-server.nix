{ config, pkgs, lib, ... }:

let
  rootPath = "/var/lib/obsidian";
  dataPath = "${rootPath}/data";
  etcPath = "${rootPath}/etc";
in
{
  systemd.services."createCouchDBFolder" = {
    script = ''
      mkdir -p ${dataPath}
      mkdir -p ${etcPath}
    '';
    wantedBy = [ "multi-user.target" ];
    before = [ "podman-couchdb.service" ];
    serviceConfig.Type = "oneshot";
  };

  virtualisation = {
    oci-containers = {
      containers = {
        couchdb = {
          image = "couchdb:latest";
          autoStart = true;
          ports = [
            "127.0.0.1:5984:5984"
          ];
          volumes = [
            "${dataPath}:/opt/couchdb/data"
            "${etcPath}:/opt/couchdb/etc/local.d"
          ];
          environmentFiles = [ config.age.secrets.obsidian_couchdb_environment_file.path ];
        };
      };
    };
  };


  systemd.services."initializeCouchDB" = {
    script = ''
      #!/bin/sh

      echo "
      [chttpd]
      bind_address = 0.0.0.0
      port = 5984
      require_valid_user = true
      enable_cors = true
      max_http_request_size = 4294967296

      [cluster]
      n = 1

      [chttpd_auth]
      require_valid_user = true

      [httpd]
      WWW-Authenticate = Basic realm='couchdb'
      enable_cors = true

      [couchdb]
      max_document_size = 50000000
      uuid = 8faa7b451bfdb7cac7c86aac49a16e35

      [cors]
      credentials = true
      origins = app://obsidian.md,capacitor://localhost,http://localhost

            " > /var/lib/obsidian/etc/docker.ini

      systemctl restart podman-couchdb.service
    '';
    wantedBy = [ "multi-user.target" ];
    after = [ "podman-couchdb.service" ];

    serviceConfig.Type = "oneshot";
  };

  services.nginx = {
    virtualHosts."obsidian.${config.globals.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:5984";
      };
    };
  };
}

