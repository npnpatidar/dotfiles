{ lib
, stdenv
, fetchurl
, nur
  # , pkgs
, ...
}:
import ./generated.nix {
  inherit lib stdenv fetchurl;
  inherit (nur.repos.rycee.firefox-addons) buildFirefoxXpiAddon;
}
