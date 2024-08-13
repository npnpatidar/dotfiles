{
  description = "System Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixvim = {
    #   url = "github:nix-community/nixvim";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
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

  outputs = { self, nixpkgs, home-manager, nix-on-droid, nix-index-database, stylix, agenix, simple-nixos-mailserver, ... } @ inputs:
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
      #oracle server  sudo nixos-rebuild test --flake .#alma  
      nixosConfigurations = {
        alma = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/oracle/nixos/configuration.nix agenix.nixosModules.default ];
        };
      };

      # oracle server 'home-manager --flake .#naresh@alma'
      homeConfigurations = {
        "naresh@alma" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/oracle/home-manager/home.nix ];
        };
      };

      #acer laptop  sudo nixos-rebuild test --flake .#aspire7  
      nixosConfigurations =
        {
          aspire7 = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs outputs; };
            system = "x86_64-linux";
            modules = [
              # { nixpkgs.overlays = [ nur.overlay ]; }
              # ({ pkgs, ... }:
              #   let
              #     nur-no-pkgs = import nur {
              #       nurpkgs = import nixpkgs { system = "x86_64-linux"; };
              #     };
              #   in
              #   {
              #     # imports = [ nur-no-pkgs.repos.iopq.modules.xraya ];
              #     # services.xraya.enable = true;
              #   })
              ./hosts/aspire7/nixos/configuration.nix
              agenix.nixosModules.default
              # nur.nixosModules.nur
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
                    # nixvim.homeManagerModules.nixvim
                    nix-index-database.hmModules.nix-index
                    stylix.homeManagerModules.stylix
                  ];
                };
              }
            ];
          };
        };

      # Mobile  nix-on-droid switch --flake .#rmx3312
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
      # acer laptop home configuration home-manager switch --flake .#naresh@aspire7
      homeConfigurations = {
        "naresh@aspire7" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/aspire7/home-manager/naresh_home.nix
            nix-index-database.hmModules.nix-index
            stylix.homeManagerModules.stylix
          ];

        };
      };
      nixosConfigurations =
        {
          qbox = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs outputs; };
            system = "x86_64-linux";
            modules = [
              ./hosts/qbox/nixos/configuration.nix
              # agenix.nixosModules.default
              # nur.nixosModules.nur
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  # useGlobalPkgs = true;
                  useUserPackages = true;
                  users.naresh = {
                    imports = [
                      ./hosts/qbox/home-manager/home.nix
                    ];
                  };

                  # extraSpecialArgs = { inherit inputs outputs; };
                  # sharedModules = [
                  #   nixvim.homeManagerModules.nixvim
                  #   nix-index-database.hmModules.nix-index
                  #   stylix.homeManagerModules.stylix
                  # ];
                };
              }
            ];
          };
        };


    };
}
