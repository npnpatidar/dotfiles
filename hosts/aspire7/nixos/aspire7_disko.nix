#  sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko aspire7_disko.nix
# look at https://github.com/nix-community/disko/blob/master/docs/quickstart.md
{
  disko.devices = {
    disk = {
      vdb = {
        device = "nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}

