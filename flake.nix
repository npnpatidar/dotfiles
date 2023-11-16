{
  description = "System Config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { nixpkgs, home-manager, ... }:

    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };

      lib = nixpkgs.lib;
    in
    {

      nixosConfiguration = {
        nixos = lib.nixosSystem {
          inherit system;

          modules = [
            ./system/configuration.nix
          ];
        };
      };

    };
}
