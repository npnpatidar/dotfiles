{ config, pkgs, lib, ... }:

let
  rootPath = "/var/lib/obsidian";
  dataPath = "${rootPath}/data";
  etcPath = "${rootPath}/etc";
  hostname = "localhost:5984";
  username = "username";     #Please change as you like.
  password = "password";
in
{

  # services.couchdb =
  #   {
  #     enable = true;
  #     port = 5984;
  #     bindAddress = "127.0.0.1";
  #     adminPass = "${password}";
  #     adminUser = "${username}";
  #   };
  # users.groups.obsidian = { };
  # users.users.obsidian = {
  #   isSystemUser = true;
  #   group = "obsidian";
  # };

  # systemd.tmpfiles.rules = [
  #   "d ${dataPath} 0755 obsidian obsidian"
  #   "d ${etcPath} 0755 obsidian obsidian"
  # ];

  systemd.tmpfiles.rules = [
    "d ${rootPath}"
    "d ${dataPath}"
    "d ${etcPath}"
  ];
  virtualisation = {
    oci-containers = {
      containers = {
        couchdb = {
          image = "couchdb:latest";
          autoStart = true;
          # user = "0:0";
          ports = [
            "127.0.0.1:5984:5984"
          ];
          volumes = [
            # "${rootPath}:/opt/couchdb"
            "${dataPath}:/opt/couchdb/data"
            "${etcPath}:/opt/couchdb/etc/local.d"
          ];
          environment = {
            COUCHDB_USER = "${username}";
            COUCHDB_PASSWORD = "${password}";
          };
          # extraOptions = [ "--pull=newer" ];
        };

      };
    };
  };


  systemd.services."initialize-couchdb" = {
    script = ''
      #!/bin/sh

      export hostname="${hostname}"
      export username="${username}" #Please change as you like.
      export password="${password}"
      #Please change as you like
      if [[ -z "$hostname" ]]; then
          echo "ERROR: Hostname missing"
          exit 1
      fi
      if [[ -z "$username" ]]; then
          echo "ERROR: Username missing"
          exit 1
      fi

      if [[ -z "$password" ]]; then
          echo "ERROR: Password missing"
          exit 1
      fi

      echo "-- Configuring CouchDB by REST APIs... -->"

      until (${pkgs.curl}/bin/curl -X POST "${hostname}/_cluster_setup" -H "Content-Type: application/json" -d "{\"action\":\"enable_single_node\",\"username\":\"${username}\",\"password\":\"${password}\",\"bind_address\":\"0.0.0.0\",\"port\":5984,\"singlenode\":true}" --user "${username}:${password}"); do sleep 5; done
      until (${pkgs.curl}/bin/curl -X PUT "${hostname}/_node/nonode@nohost/_config/chttpd/require_valid_user" -H "Content-Type: application/json" -d '"true"' --user "${username}:${password}"); do sleep 5; done
      until (${pkgs.curl}/bin/curl -X PUT "${hostname}/_node/nonode@nohost/_config/chttpd_auth/require_valid_user" -H "Content-Type: application/json" -d '"true"' --user "${username}:${password}"); do sleep 5; done
      until (${pkgs.curl}/bin/curl -X PUT "${hostname}/_node/nonode@nohost/_config/httpd/WWW-Authenticate" -H "Content-Type: application/json" -d '"Basic realm=\"couchdb\""' --user "${username}:${password}"); do sleep 5; done
      until (${pkgs.curl}/bin/curl -X PUT "${hostname}/_node/nonode@nohost/_config/httpd/enable_cors" -H "Content-Type: application/json" -d '"true"' --user "${username}:${password}"); do sleep 5; done
      until (${pkgs.curl}/bin/curl -X PUT "${hostname}/_node/nonode@nohost/_config/chttpd/enable_cors" -H "Content-Type: application/json" -d '"true"' --user "${username}:${password}"); do sleep 5; done
      until (${pkgs.curl}/bin/curl -X PUT "${hostname}/_node/nonode@nohost/_config/chttpd/max_http_request_size" -H "Content-Type: application/json" -d '"4294967296"' --user "${username}:${password}"); do sleep 5; done
      until (${pkgs.curl}/bin/curl -X PUT "${hostname}/_node/nonode@nohost/_config/couchdb/max_document_size" -H "Content-Type: application/json" -d '"50000000"' --user "${username}:${password}"); do sleep 5; done
      until (${pkgs.curl}/bin/curl -X PUT "${hostname}/_node/nonode@nohost/_config/cors/credentials" -H "Content-Type: application/json" -d '"true"' --user "${username}:${password}"); do sleep 5; done
      until (${pkgs.curl}/bin/curl -X PUT "${hostname}/_node/nonode@nohost/_config/cors/origins" -H "Content-Type: application/json" -d '"app://obsidian.md,capacitor://localhost,http://localhost"' --user "${username}:${password}"); do sleep 5; done

      echo "<-- Configuring CouchDB by REST APIs Done!"

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

