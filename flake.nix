{
  description = "System Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    # nixvim.url = "github:pta2002/nixvim";
    nixneovimplugins.url = "github:jooooscha/nixpkgs-vim-extra-plugins";
    codeium.url = "github:Exafunction/codeium.nvim";
    nix-on-droid = {
      url = "github:t184256/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nur, home-manager, nixvim, nix-on-droid, nix-index-database, stylix, ... } @ inputs:
    let

      inherit (self) outputs;
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      # lib = nixpkgs.lib;
    in
    rec {
      nixosConfigurations =
        {
          aspire7 = nixpkgs.lib.nixosSystem {
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
                  # imports = [ nur-no-pkgs.repos.iopq.modules.xraya ];
                  # services.xraya.enable = true;
                })
              ./hosts/aspire7/nixos/configuration.nix

              nur.nixosModules.nur
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  # useGlobalPkgs = true;
                  useUserPackages = true;
                  users.naresh = {
                    imports = [
                      ./hosts/aspire7/home-manager/home.nix
                    ];
                  };

                  extraSpecialArgs = { inherit inputs outputs; };
                  sharedModules = [
                    nixvim.homeManagerModules.nixvim
                    nix-index-database.hmModules.nix-index
                    stylix.homeManagerModules.stylix
                  ];
                };
              }
            ];
          };
        };


      nixOnDroidConfigurations.rmx3312 = nix-on-droid.lib.nixOnDroidConfiguration {
        modules = [
          ./hosts/rmx3312/nix-on-droid.nix
        ];
      };
    };
}
