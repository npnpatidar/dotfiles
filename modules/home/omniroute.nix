_: {
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
            publishPorts = [ "20128:20128" ];
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
