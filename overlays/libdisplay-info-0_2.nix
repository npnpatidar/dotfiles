# libdisplay-info 0.2.0 — removed from nixpkgs (aliases.nix throws on access) but
# still required by niri-flake's make-niri (assert libdisplay-info_0_2.version == "0.2.0").
# Recreate it as a nixpkgs input overlay so `inputs.niri.packages.*.niri-unstable`
# (and anything consuming `inputs.nixpkgs.legacyPackages`) can build against it.
# Source hash is the one shipped in nixpkgs pkgs/by-name/li/libdisplay-info/0.2.nix.
_final: prev: {
  libdisplay-info_0_2 = prev.callPackage (
    {
      lib,
      stdenv,
      fetchFromGitLab,
      meson,
      pkg-config,
      ninja,
      python3,
      hwdata,
    }:
    stdenv.mkDerivation (finalAttrs: {
      pname = "libdisplay-info";
      version = "0.2.0";

      src = fetchFromGitLab {
        hash = "sha256-6xmWBrPHghjok43eIDGeshpUEQTuwWLXNHg7CnBUt3Q=";
        domain = "gitlab.freedesktop.org";
        owner = "emersion";
        repo = "libdisplay-info";
        tag = finalAttrs.version;
      };

      strictDeps = true;
      __structuredAttrs = true;

      depsBuildBuild = [ pkg-config ];
      nativeBuildInputs = [
        meson
        pkg-config
        ninja
        hwdata
        python3
      ];

      postPatch = ''
        patchShebangs tool/gen-search-table.py
      '';

      meta = {
        description = "EDID and DisplayID library (0.2.0, kept for niri)";
        homepage = "https://gitlab.freedesktop.org/emersion/libdisplay-info";
        license = lib.licenses.mit;
        platforms = lib.platforms.linux ++ lib.platforms.freebsd;
      };
    })
  ) { };
}
