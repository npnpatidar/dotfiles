let
  pname = "filen-desktop";
  version = "2.0.24";
  rev = "1"; # Update this when you make changes to the derivation

in
{ pkgs ? import <nixpkgs> { } }:
pkgs.appimageTools.wrapType2 {
  name = "filen-desktop";
  src = pkgs.fetchurl {
    url = "https://cdn.filen.io/desktop/release/filen_x86_64.AppImage";
    sha256 = "sha256-5vkndT9V/81fUdzS+KTfAjPAGO0IJRx8QhNxBNG8nnU=";
  };
}


