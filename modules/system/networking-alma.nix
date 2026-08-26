_: {
  flake.nixosModules.networking-alma = {
    networking = {
      domain = "";
      firewall.allowedTCPPorts = [
        443
        80
        853 # DNS-over-TLS for Android Private DNS
        46587 # public SSH (must stay open: no more tailscale fallback)
      ];
    };
  };
}
