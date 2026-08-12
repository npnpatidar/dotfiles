_: {
  flake.nixosModules.nvidia = { config, pkgs, ... }: {
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };

      nvidia-container-toolkit = {
        enable = true;
        suppressNvidiaDriverAssertion = true;
      };
      nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        powerManagement.finegrained = true;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.production;
        prime = {
          offload.enable = true;
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };
      };
    };

    nixpkgs.config.cudaVersion = "12.4";
    environment.systemPackages = with pkgs; [
      cudaPackages.cudatoolkit
      (writeShellScriptBin "nvidia-offload" ''
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export VK_LOADER_DRIVERS_SELECT=nvidia
        exec "$@"
      '')
    ];

    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
