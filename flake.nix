{
  description = "System Config";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, home-manager, ... }:

    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      lib = nixpkgs.lib;
    in
    {
      nixosConfigurations = {
        naresh = lib.nixosSystem {
          inherit system pkgs;

          modules = [

          ./system/configuration.nix
      #  .system/hardware-configuration.nix
             home-manager.nixosModules.home-manager {
               home-manager.useGlobalPkgs = true;
               home-manager.useUserPackages = true;
               home-manager.users.naresh = {
                 imports = [ ./users/naresh/home.nix
            ];
              };
            }
          ];
        };
      };

    };
}
