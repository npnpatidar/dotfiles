_: {
  flake.nixosModules.alma-hardware = { modulesPath, ... }: {
    imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
    boot = {
      loader = {
        efi.efiSysMountPoint = "/boot/efi";
        grub = {
          efiSupport = true;
          efiInstallAsRemovable = true;
          device = "nodev";
        };
      };
      initrd.availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "xen_blkfront"
      ];
      initrd.kernelModules = [ "nvme" ];
    };
    fileSystems."/boot/efi" = {
      device = "/dev/disk/by-uuid/12A7-EDF0";
      fsType = "vfat";
    };
    fileSystems."/" = {
      device = "/dev/sda3";
      fsType = "xfs";
    };

    hardware.facter.reportPath = ./alma-facter.json;
    nixpkgs.hostPlatform = "aarch64-linux";
    system.stateVersion = "26.05";
  };
}
