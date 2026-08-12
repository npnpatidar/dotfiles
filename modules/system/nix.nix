{ lib, ... }: with lib;
{
  flake.nixosModules.nix = { config, pkgs, ... }: {
    boot.tmp.cleanOnBoot = true;
    zramSwap.enable = true;

    nix = {
      package = pkgs.nixVersions.latest;
      extraOptions = "experimental-features = nix-command flakes";
      settings = {
        auto-optimise-store = true;
        trusted-users = [
          "root"
          "${config.systemConstants.default_user}"
        ];
        substituters = [
          "https://cache.nixos.org"
          "https://npnpatidar.cachix.org"
          "https://zen-browser.cachix.org"
          "https://noctalia.cachix.org"
          "https://niri.cachix.org"
          "https://cuda-maintainers.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "npnpatidar.cachix.org-1:slDM+6A9sX+ETHd9PttkqYHimtAjJ065Lj7fN/TBmrQ="
          "zen-browser.cachix.org-1:z/QLGrEkiBYF/7zoHX1Hpuv0B26QrmbVBSy9yDD2tSs="
          "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
          "niri.cachix.org-1:Wv0OmO7mTCuLCqXZff9iL4mQ5bMg2EbosB4rCnWZosg="
          "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
        ];
      };
      optimise.automatic = true;
      optimise.dates = [ "03:45" ];
      gc = {
        automatic = false;
        dates = "weekly";
        options = "--delete-older-than 3d";
      };
    };

    nixpkgs.config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "pnpm-9.15.9"
      ];
    };

    programs.nix-ld.enable = true;

    programs = {
      nh = {
        enable = true;
        clean = {
          enable = true;
          dates = "daily";
          extraArgs = "--no-direnv";
        };
        flake = "${config.systemConstants.home_directory}/dotfiles";
      };
      fuse = {
        enable = true;
        userAllowOther = true;
      };
    };
  };
}
