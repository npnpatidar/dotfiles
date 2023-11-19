 
# { lib, fetchurl, stdenv, appimageTools }:

# stdenv.mkDerivation rec {
#   pname = "thorium";
#   version = "117.0.5938.157";
#   rev = "1";  # Update this when you make changes to the derivation

#   src = fetchurl {
#     url = "https://github.com/Alex313031/thorium/releases/download/M${version}/Thorium_Browser_${version}_x64.AppImage";
#     sha256 = "000000000000000000000000000000000000000000000000000000";  # You can compute this using 'nix-prefetch-url'
#   };

#   nativeBuildInputs = [ appimageTools ];

#   installPhase = ''
#     mkdir -p $out/bin
#     cp $src $out/bin/thorium
#     chmod +x $out/bin/thorium
#   '';

#   meta = with lib; {
#     description = "Thorium Browser";
#     license = licenses.mit;
#   };
# }



let
  pname = "thorium";
  version = "117.0.5938.157";
  rev = "1";  # Update this when you make changes to the derivation

in { pkgs ? import <nixpkgs> {} }:
pkgs.appimageTools.wrapType2 {
  name = "thorium_browser";
  src = pkgs.fetchurl {
     url = "https://github.com/Alex313031/thorium/releases/download/M${version}/Thorium_Browser_${version}_x64.AppImage";
   sha256 = "sha256-dlfClBbwSkQg4stKZdSgNg3EFsWksoI21cxRG5SMrOM=";
  };
}