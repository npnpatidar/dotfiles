_: {
  # Freebuff — the free coding agent CLI (https://freebuff.com).
  # The package itself lives in pkgs/freebuff.nix.
  flake.homeModules.freebuff = { pkgs, ... }: {
    home.packages = [
      (import ../../pkgs/freebuff.nix { inherit pkgs; })
    ];
  };
}
