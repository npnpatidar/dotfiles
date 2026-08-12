_: {
  flake.nixosModules.aspire7-hardware =
    {
      modulesPath,
      config,
      lib,
      ...
    }:
    {
      imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

      boot = {
        initrd.availableKernelModules = [
          "xhci_pci"
          "thunderbolt"
          "vmd"
          "nvme"
        ];
        initrd.kernelModules = [ ];
        kernelModules = [ "kvm-intel" ];
        extraModulePackages = [ ];
      };

      fileSystems = {
        "/" = {
          device = "/dev/disk/by-label/NIXROOT";
          fsType = "ext4";
          options = [ "noatime" ];
        };
        "/boot" = {
          device = "/dev/disk/by-label/NIXBOOT";
          fsType = "vfat";
          options = [ "noatime" ];
        };
        "${config.systemConstants.data_directory}" = {
          device = "/dev/disk/by-label/NIXDATA";
          fsType = "ext4";
          options = [ "noatime" ];
        };
      };

      swapDevices = [ ];

      networking.useDHCP = lib.mkDefault false;

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.facter.reportPath = ./aspire7-facter.json;
      system.stateVersion = "23.05";
      powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
