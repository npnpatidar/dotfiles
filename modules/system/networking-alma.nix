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
    # required for tailscale exit-node (forward tailnet traffic out)
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
  };
}
