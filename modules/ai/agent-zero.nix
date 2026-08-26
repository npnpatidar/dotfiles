_: {
  flake.nixosModules.agent-zero = { config, ... }: {
    services.nginx.virtualHosts."agento.${config.systemConstants.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://127.0.0.1:7665";
      };
    };
  };

  flake.homeModules.agent-zero = { config, inputs, ... }: {
    home.file."Data/podman/agent0/.keep".text = "";
    imports = [ inputs.quadlet-nix.homeManagerModules.quadlet ];
    virtualisation.quadlet.containers.agent0 = {
      autoStart = true;
      serviceConfig = {
        RestartSec = "10";
        Restart = "always";
      };
      containerConfig = {
        image = "agent0ai/agent-zero";
        # Shared bridge network: aardvark-dns resolves via host's resolver chain.
        networks = [ "services" ];
        volumes = [ "//${config.systemConstants.data_directory}/podman/agent0/:/a0" ];
        publishPorts = [ "127.0.0.1:7665:80" ];
        environments = {
          ALLOWED_ORIGINS = "https://agento.${config.systemConstants.domain_name}";
        };
      };
    };
  };
}
