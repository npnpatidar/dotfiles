_:
let
  dracula =
    pkgs:
    pkgs.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixos-artwork";
      rev = "e3a74d1c40086393f2b1b9f218497da2db0ff3ae";
      sha256 = "sha256-9MRBDosbxEXNUWRimzBcyfmYtSQ/2GAliYUqA8A8GkY=";
      sparseCheckout = [ "wallpapers" ];
    }
    + "/wallpapers"
    + "/nix-wallpaper-dracula.png";

  abstract-swirls =
    pkgs:
    pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/orangci/walls-catppuccin-mocha/master/abstract-swirls.jpg";
      sha256 = "sha256-QyvJgQ7FHLoFmeVc9HPQSnOEmT0aAEpWFblh6PDyluw=";
    };
in
{
  flake = {
    nixosModules.wallpaper = _: {
      # This module can be used to access wallpapers
    };

    homeModules.wallpaper = _: {
      # Wallpapers available via config
    };

    wallpapers = {
      inherit dracula abstract-swirls;
    };
  };
}
