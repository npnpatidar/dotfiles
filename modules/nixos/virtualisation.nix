{ ... }:
{

  virtualisation.libvirtd.enable = true;
  virtualisation.vmVariant = {
    # following configuration is added only when building VM with build-vm
    virtualisation = {
      memorySize = 4096; # Use 2048MiB memory.
      cores = 8;
      diskSize = 10 * 1024;
      sharedDirectories = {
        my-share = {
          source = "/home/naresh/VMShare";
          target = "/mnt/SharedToHost";
        };
      };
      resolution = {
        x = 1440;
        y = 900;
      };
    };
  };


}
