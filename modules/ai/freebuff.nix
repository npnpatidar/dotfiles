_: {
  # Freebuff — the free coding agent CLI (https://freebuff.com).
  #
  # Installed declaratively from the npm tarball. To bump versions:
  #   1. Get the new tarball url/hash from `curl -s https://registry.npmjs.org/freebuff/latest`.
  #   2. Regenerate the vendored lockfile: `npm install --package-lock-only` in an
  #      extracted copy, copy it to ./freebuff/package-lock.json.
  #   3. Set npmDepsHash = lib.fakeHash, build, copy the reported `got:` hash back.
  flake.homeModules.freebuff = { pkgs, ... }: {
    home.packages = [
      (pkgs.buildNpmPackage {
        pname = "freebuff";
        version = "0.0.146";

        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/freebuff/-/freebuff-0.0.146.tgz";
          hash = "sha256-cnpvtnZqpMqgi6XT94ojU7aBCgLq5yMkrmkvZTiGvRU=";
        };

        npmDepsHash = "sha256-Od9UBoiuU+VnZ+iqOL40/ahvDxRFLwbI91bB+Vj4II8=";

        # Vendor the lockfile (the published tarball has none) and drop the
        # monorepo-only prepack/postpack scripts that would otherwise fail
        # `npm pack` during the install phase.
        postPatch = ''
          cp ${./freebuff-lock.json} package-lock.json
          ${pkgs.jq}/bin/jq 'del(.scripts.prepack, .scripts.postpack)' package.json > package.json.tmp
          mv package.json.tmp package.json
        '';

        dontNpmBuild = true;
      })
    ];
  };
}
