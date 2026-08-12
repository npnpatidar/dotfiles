_: {
  flake.nixosModules.networking-alma = {
    networking = {
      domain = "";
      firewall.allowedTCPPorts = [
        443
        80
        853 # DNS-over-TLS for Android Private DNS
      ];
    };
  };
}
