_: {
  flake.nixosModules.containerization-aspire7 = { config, pkgs, ... }: {
    virtualisation = {
      podman.dockerCompat = true;
      containers.enable = true;
      libvirtd.enable = false;
    };

    virtualisation.vmVariant = {
      virtualisation = {
        memorySize = 4096;
        cores = 8;
        diskSize = 10 * 1024;
        sharedDirectories."my-share" = {
          source = "${config.systemConstants.home_directory}/VMShare";
          target = "/mnt/SharedToHost";
        };
        resolution = {
          x = 1440;
          y = 900;
        };
      };
    };

    environment.systemPackages = with pkgs; [
      docker-compose
      docker-client
    ];
  };
}
