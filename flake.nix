{
  description = "System Config";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };


  };

  outputs = { nixpkgs, home-manager, plasma-manager, ... }:

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
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.naresh = {
                  imports = [ ./users/naresh/home.nix ];
                };
                sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
              };
            }
          ];
        };
      };
    };
}
