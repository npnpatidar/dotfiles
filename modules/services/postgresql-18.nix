# Keep PostgreSQL at version 18.
#
# `system.stateVersion` is 23.05, which makes the nixpkgs default resolve to
# the removed `postgresql_14` package and fails to evaluate. The Immich
# database was migrated from PostgreSQL 14 to 18 on 2026-11-20; the old
# cluster remains at /var/lib/postgresql/14 for rollback.
_: {
  flake.nixosModules.postgresql-18 =
    { pkgs, ... }:
    {
      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_18;
      };
    };
}
