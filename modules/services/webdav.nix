_: {
  flake.nixosModules.webdav =
    { config, ... }:
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
    in
    {
      sops.secrets.webdav_environment_file = {
        sopsFile = ../../secrets/alma.yaml;
      };
      sops.secrets.webdav_mount_file = {
        sopsFile = ../../secrets/alma.yaml;
      };

      systemd.services.webdav.serviceConfig.EnvironmentFile =
        config.sops.secrets.webdav_environment_file.path;

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
