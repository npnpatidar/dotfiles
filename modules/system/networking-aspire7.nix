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
        ];
        allowedUDPPortRanges = [
          {
            from = 1714;
            to = 1764;
          }
        ];

        allowedTCPPorts = [
          2283
          53317
          22000
        ];
        allowedUDPPorts = [
          21027
          22000
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
