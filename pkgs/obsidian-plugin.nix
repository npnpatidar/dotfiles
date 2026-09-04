{ pkgs, lib }:

# Build an Obsidian community plugin package from a GitHub release.
#
# Obsidian looks for a plugin in `.obsidian/plugins/<manifest.id>/`, so each
# package installs the release assets (`main.js`, `manifest.json` and
# optionally `styles.css`) at the derivation root, which home-manager's
# `programs.obsidian` module then copies into the vault.
#
# Args:
#   id            - plugin id, must match the `id` field in manifest.json
#                   (this becomes the install folder name)
#   repo          - "owner/name" of the GitHub repository
#   version       - release tag to fetch
#   mainJsHash    - sha256 (base32) of `<version>/main.js`
#   manifestHash  - sha256 (base32) of `<version>/manifest.json`
#   stylesCssHash - optional sha256 (base32) of `<version>/styles.css`
#
# To bump versions:
#   1. Check latest releases: `curl -s https://api.github.com/repos/<repo>/releases/latest`
#   2. Download each asset and get hashes with `nix hash file <file>`.
{
  id,
  repo,
  version,
  mainJsHash,
  manifestHash,
  stylesCssHash ? null,
}:

let
  fetchAsset =
    file: sha256:
    pkgs.fetchurl {
      url = "https://github.com/${repo}/releases/download/${version}/${file}";
      inherit sha256;
    };
in
pkgs.stdenv.mkDerivation {
  pname = "obsidian-plugin-${id}";
  inherit version;

  dontUnpack = true;

  mainJs = fetchAsset "main.js" mainJsHash;
  manifest = fetchAsset "manifest.json" manifestHash;
  stylesCss = if stylesCssHash != null then fetchAsset "styles.css" stylesCssHash else null;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp "$mainJs" "$out/main.js"
    cp "$manifest" "$out/manifest.json"
  ''
  + lib.optionalString (stylesCssHash != null) ''
    cp "$stylesCss" "$out/styles.css"
  ''
  + ''
    runHook postInstall
  '';

  meta = with lib; {
    description = "Obsidian community plugin package";
    homepage = "https://github.com/${repo}";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.mit;
    platforms = platforms.all;
  };
}
