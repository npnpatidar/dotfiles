{ ... }:
{




  # Networking
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPortRanges = [

        { from = 1714; to = 1764; }
        { from = 22000; to = 22000; }
        { from = 53317; to = 53317; }
      ];
      allowedUDPPortRanges = [

        { from = 1714; to = 1764; }

        { from = 22000; to = 22000; }
        { from = 21027; to = 21027; }
      ];
    };
  };
}
