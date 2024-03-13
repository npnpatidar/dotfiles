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
    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    # nixvim.url = "github:pta2002/nixvim";
    # nixneovimplugins.url = "github:jooooscha/nixpkgs-vim-extra-plugins";
    # codeium.url = "github:Exafunction/codeium.nvim";
    nix-on-droid = {
      url = "github:t184256/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # arkenfox = {
    #   url = "github:dwarfmaster/arkenfox-nixos";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # firefox-addons = {
    #   url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    # };
  };

  outputs = { self, nixpkgs, nur, home-manager, nix-on-droid, nix-index-database, stylix, nixvim, ... } @ inputs:
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
                      ./hosts/aspire7/home-manager/naresh_home.nix
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
        modules = [ ./hosts/rmx3312/nix-on-droid.nix ];
        pkgs = import nixpkgs {
          system = "aarch64-linux";
          config.allowUnfree = true;
          config.permittedInsecurePackages = [
            "tightvnc-1.3.10"
          ];
        };
      };

      homeConfigurations = {
        # FIXME replace with your username@hostname
        "naresh" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/aspire7/home-manager/home.nix
            nix-index-database.hmModules.nix-index
            stylix.homeManagerModules.stylix
          ];

        };
      };


      nixosConfigurations = {
        exampleIso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
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
                  nix-index-database.hmModules.nix-index
                  stylix.homeManagerModules.stylix
                ];
              };
            }
          ];

        };
      };

      nixosConfigurations =
        {
          aspireM = nixpkgs.lib.nixosSystem {
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
              # {
              #   home-manager = {
              #     # useGlobalPkgs = true;
              #     useUserPackages = true;
              #     users.naresh = {
              #       imports = [
              #         ./hosts/aspire7/home-manager/home.nix
              #       ];
              #     };
              #
              #     extraSpecialArgs = { inherit inputs outputs; };
              #     sharedModules = [
              #       nixvim.homeManagerModules.nixvim
              #       nix-index-database.hmModules.nix-index
              #       stylix.homeManagerModules.stylix
              #     ];
              #   };
              # }
            ];
          };
        };





    };
}
