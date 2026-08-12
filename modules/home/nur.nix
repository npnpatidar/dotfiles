_: {
  flake.homeModules.nur = { inputs, ... }: {
    nixpkgs.overlays = [ inputs.nur.overlays.default ];
  };
}
