{ lib, ... }: with lib;
{
  flake.nixosModules.networking-aspire7 = { lib, ... }: with lib;
    {
      networking.firewall = {
        allowedTCPPortRanges = [
          {
            from = 1714;
            to = 1764;
          }
          {
            from = 22000;
            to = 22000;
          }
          {
            from = 53317;
            to = 53317;
          }
        ];
        allowedUDPPortRanges = [
          {
            from = 1714;
            to = 1764;
          }
          {
            from = 22000;
            to = 22000;
          }
          {
            from = 21027;
            to = 21027;
          }
        ];
      };

      systemd = {
        services.ModemManager.enable = lib.mkForce false;
        network.links."40-wol" = {
          matchConfig.Path = "*-wl*";
          linkConfig.WakeOnLan = "off";
        };
        network.links."41-wol" = {
          matchConfig.Path = "*-enp*";
          linkConfig.WakeOnLan = "off";
        };
      };
    };
}
