_: {
  flake.nixosModules.tailscale-alma = {
    services.tailscale.extraUpFlags = [ "--advertise-exit-node" ];
  };
}
