{ lib, ... }: with lib;
{
  flake.nixosModules.networking = _: {
    networking = {
      networkmanager.enable = true;
      useDHCP = false;
      dhcpcd.enable = false;
      firewall = {
        enable = true;
      };
    };
  };
}
