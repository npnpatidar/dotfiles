{
  description = "System Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
stylix.url = "github:danth/stylix";
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

  outputs = { self, nixpkgs, nur, home-manager, plasma-manager,stylix, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
    in
    rec {
      nixosConfigurations =
        {
          naresh = lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              { nixpkgs.overlays = [ nur.overlay ]; }
              ({ pkgs, ... }:
                let
                  nur-no-pkgs = import nur {
                    nurpkgs = import nixpkgs { system = "x86_64-linux"; };
                  };
                in
                {
                  imports = [ nur-no-pkgs.repos.iopq.modules.xraya ];
                  services.xraya.enable = true;
                })
              ./system/configuration.nix

              nur.nixosModules.nur
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.naresh = {
                    imports = [
                      ./users/naresh/home.nix
                    ];
                  };
                  sharedModules = [ plasma-manager.homeManagerModules.plasma-manager stylix.homeManagerModules.stylix];
                };
              }
            ];
          };
        };
    };
}
