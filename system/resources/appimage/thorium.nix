let
  pname = "thorium";
  version = "117.0.5938.157";
  rev = "1"; # Update this when you make changes to the derivation

in
{ pkgs ? import <nixpkgs> { } }:
pkgs.appimageTools.wrapType2 {
  name = "thorium_browser";
  src = pkgs.fetchurl {
    url = "https://github.com/Alex313031/thorium/releases/download/M${version}/Thorium_Browser_${version}_x64.AppImage";
    sha256 = "sha256-dlfClBbwSkQg4stKZdSgNg3EFsWksoI21cxRG5SMrOM=";
  };
}
