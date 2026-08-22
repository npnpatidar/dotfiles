_: {
  flake.nixosModules.omniroute = { config, ... }: {
    services.oink.domains = [
      {
        domain = "${config.systemConstants.domain_name}";
        subdomain = "omniroute";
      }
    ];
    services.nginx.virtualHosts."omniroute.${config.systemConstants.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      # Dashboard behind Tinyauth; OpenAI-compatible API stays key-authed.
      enableTinyauth = true;
      locations."/v1/" = {
        proxyPass = "http://127.0.0.1:20128";
        proxyWebsockets = true;
      };
      locations."/" = {
        proxyPass = "http://127.0.0.1:20128";
        proxyWebsockets = true;
      };
    };
  };

  flake.homeModules.omniroute = { config, ... }: {
    virtualisation.quadlet = {
      enable = true;
      containers = {
        omniroute = {
          autoStart = true;
          serviceConfig = {
            Restart = "always";
            RestartSec = "10";
            Description = "OmniRoute - Unified AI Gateway";
          };
          containerConfig = {
            image = "docker.io/diegosouzapw/omniroute:latest";
            publishPorts = [ "127.0.0.1:20128:20128" ];
            volumes = [ "${config.systemConstants.data_directory}/Sync_L_O/podman/omniroute:/app/data:Z" ];
            environments = {
              PORT = "20128";
            };
          };
        };
      };
    };
  };
}
