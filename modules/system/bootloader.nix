{ inputs, ... }: {
  flake.nixosModules.bootloader-aspire7 = { pkgs, ... }: {
    imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];
    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      supportedFilesystems = [ "ntfs" ];
      kernelParams = [
        "8250.nr_uarts=0"
        "i915.enable_dc=2"
        "i915.enable_psr=2"
        "i915.enable_fbc=1"
        "i915.enable_guc=2"
        "i915.enable_rc6=1"
        "pcie_aspm.policy=powersupersave"
        "nvme_core.default_ps_max_latency_us=5500"
        "snd_hda_intel.power_save=1"
        "snd_hda_intel.power_save_controller=Y"
        "iwlwifi.power_save=1"
        "drm.vblankoffdelay=1"
        "usbcore.autosuspend=1"
        "nvme_core.default_ps_latency_aggregate_policy=0"
        "pci=noaer"
        "nvidia_drm.fbdev=0"
        "workqueue.power_efficient=1"
      ];
      blacklistedKernelModules = [ "serial8250" ];
      loader = {
        systemd-boot.enable = false;
        efi.canTouchEfiVariables = true;
      };
      lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };
    };
  };
}
