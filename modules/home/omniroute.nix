_: {
  flake.homeModules.omniroute = _: {
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
            volumes = [ "omniroute-data:/app/data" ];
            environments = {
              PORT = "20128";
            };
          };
        };
      };
    };
  };
}
