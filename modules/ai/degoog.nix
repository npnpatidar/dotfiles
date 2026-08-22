_: {
  flake.nixosModules.degoog = { config, ... }: {
    sops.secrets.degoog_settings_password = {
      sopsFile = ../../secrets/alma.yaml;
      mode = "0600";
      owner = "${config.systemConstants.default_user}";
    };

    services.oink.domains = [
      {
        domain = "${config.systemConstants.domain_name}";
        subdomain = "degoog";
      }
    ];
    services.nginx.virtualHosts."degoog.${config.systemConstants.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      enableTinyauth = true;
      locations."/" = {
        proxyPass = "http://localhost:4444";
        proxyWebsockets = true;
      };
    };
  };

  flake.homeModules.degoog =
    {
      config,
      inputs,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.quadlet-nix.homeManagerModules.quadlet ];

      systemd.user.services.degoog-dir = {
        Unit = {
          Description = "Create degoo data directory";
          Before = [ "container@degoog.service" ];
          Wants = [ "container@degoog.service" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.coreutils}/bin/mkdir -p %h/.local/share/degoog";
          RemainAfterExit = true;
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };

      virtualisation.quadlet.containers.degoog = {

        autoStart = true;
        serviceConfig = {
          RestartSec = "10";
          Restart = "always";
        };
        containerConfig = {
          image = "ghcr.io/degoog-org/degoog:latest";
          publishPorts = [ "127.0.0.1:4444:4444" ];
          volumes = [ "${config.home.homeDirectory}/.local/share/degoog:/app/data" ];
          environments = {
            TZ = "Asia/Kolkata";
          };
          environmentFiles = [ "/run/secrets/degoog_settings_password" ];
        };
      };
    };
}
