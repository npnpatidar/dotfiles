_: {
  # Shared user-defined podman bridge network for all quadlet containers.
  # Unlike the default pasta mode (which copies the host's resolv.conf into
  # containers — breaking link-local/Tailscale resolvers), this network runs
  # aardvark-dns which resolves container queries and forwards upstream ones
  # through the host's own resolver chain. No DNS IPs hardcoded anywhere.
  flake.homeModules.podman-network =
    {
      inputs,
      ...
    }:
    {
      imports = [ inputs.quadlet-nix.homeManagerModules.quadlet ];

      virtualisation.quadlet.networks.services = {
        networkConfig = {
          driver = "bridge";
        };
      };
    };
}
