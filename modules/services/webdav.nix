_: {
  flake.nixosModules.webdav =
    { config, pkgs, ... }:
    let
      webdavSettings = {
        address = "127.0.0.1";
        port = 8475;
        behindProxy = true;
        directory = "/mnt/filen/";
        permissions = "CRUD";
        users = [
          {
            username = "{env}WEBDAV_USERNAME";
            password = "{env}WEBDAV_PASSWORD";
          }
        ];
      };
      # Second instance for the home directory, bound to wg0 only (the public
      # vhost stays pointed at Filen). wg0 is a trusted firewall interface, so
      # only VPN peers can reach this port; it is plain HTTP inside WireGuard.
      homeWebdavConfig = pkgs.writeText "webdav-home.yaml" ''
        %YAML 1.1
        ---
        address: 10.100.0.1
        port: 8476
        behindProxy: false
        directory: ${config.systemConstants.home_directory}
        permissions: CRUD
        users:
        - password: '{env}WEBDAV_PASSWORD'
          username: '{env}WEBDAV_USERNAME'
      '';
    in
    {
      sops.secrets.webdav_environment_file = {
        sopsFile = ../../secrets/alma.yaml;
      };

      systemd = {
        services.webdav.serviceConfig.EnvironmentFile = config.sops.secrets.webdav_environment_file.path;

        services.webdav-home = {
          description = "WebDAV server for /home/naresh (WireGuard only)";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.webdav}/bin/webdav -c ${homeWebdavConfig}";
            EnvironmentFile = config.sops.secrets.webdav_environment_file.path;
            User = config.systemConstants.default_user;
            Group = "users";
            Restart = "on-failure";
          };
          wantedBy = [ "multi-user.target" ];
        };
      };

      services = {
        oink.domains = [
          {
            domain = "${config.systemConstants.domain_name}";
            subdomain = "dav";
          }
        ];

        webdav = {
          enable = true;
          settings = webdavSettings;
        };

        nginx.virtualHosts."dav.${config.systemConstants.domain_name}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:8475";
            proxyWebsockets = true;
            extraConfig = "client_max_body_size 1G;";
          };
        };
      };
    };
}
