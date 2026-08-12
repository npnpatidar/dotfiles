_: {
  # Freebuff — the free coding agent CLI (https://freebuff.com).
  #
  # Installed declaratively from the npm tarball. To bump versions:
  #   1. Get the new tarball url/hash from `curl -s https://registry.npmjs.org/freebuff/latest`.
  #   2. Regenerate the vendored lockfile: `npm install --package-lock-only` in an
  #      extracted copy, copy it to ./freebuff-lock.json.
  # Dependencies resolve via `importNpmLock` from the lockfile's integrity
  # hashes — no npmDepsHash guessing on bumps.
  flake.homeModules.freebuff =
    { pkgs, ... }:
    let
      pname = "freebuff";
      version = "0.0.146";

      tarball = pkgs.fetchurl {
        url = "https://registry.npmjs.org/freebuff/-/freebuff-0.0.146.tgz";
        hash = "sha256-cnpvtnZqpMqgi6XT94ojU7aBCgLq5yMkrmkvZTiGvRU=";
      };

      # The published tarball ships no lockfile and carries monorepo-only
      # prepack/postpack scripts that would fail `npm pack` in the install
      # phase — vendor the lockfile and strip those scripts upfront.
      src = pkgs.runCommand "${pname}-src" { inherit pname version; } ''
        mkdir -p $out
        tar -xzf ${tarball} -C $out --strip-components=1
        cp ${./freebuff-lock.json} $out/package-lock.json
        ${pkgs.jq}/bin/jq 'del(.scripts.prepack, .scripts.postpack)' $out/package.json > $out/package.json.tmp
        mv $out/package.json.tmp $out/package.json
      '';
    in
    {
      home.packages = [
        (pkgs.buildNpmPackage {
          inherit pname version src;

          npmDeps = pkgs.importNpmLock { npmRoot = src; };
          npmConfigHook = pkgs.importNpmLock.npmConfigHook;

          dontNpmBuild = true;
        })
      ];
    };
}
