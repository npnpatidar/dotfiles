{ inputs, ... }: {
  flake.nixosModules.overlays = { pkgs, ... }: {
    nixpkgs.overlays = [
      (final: _prev: {
        nur = import inputs.nur { inherit (final) config pkgs; };
      })
    ];
  };
}
