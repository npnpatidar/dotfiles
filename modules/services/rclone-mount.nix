_: {
  flake.nixosModules.rclone-mount =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    with lib;
    let
      uid = 1000;
      gid = 1000;
      mkRcloneMount =
        remote:
        lib.nameValuePair "/mnt/${remote}" {
          device = "${remote}:";
          fsType = "rclone";
          options = [
            "rw"
            "allow_other"
            "_netdev"
            "nofail"
            "x-systemd.automount"
            "x-systemd.requires=network-online.target"
            "env.PATH=/run/wrappers/bin"
            "config=${config.sops.secrets.rclone_config.path}"
            "cache_dir=/tmp/remote/${remote}"
            "uid=${toString uid}"
            "gid=${toString gid}"
            "umask=002"
            "dir-cache-time=48h"
            "vfs-cache-mode=full"
            "vfs-read-chunk-size=10M"
            "vfs-read-chunk-size-limit=512M"
            "buffer-size=512M"
            "no-modtime"
          ];
        };
    in
    {
      sops.secrets.rclone_config = { };

      system.fsPackages = [ pkgs.rclone ];
      fileSystems = builtins.listToAttrs (
        map mkRcloneMount [
          "koofrCrypt"
          "megaCrypt"
          "npnpatidarCrypt"
          "naresh.alternateCrypt"
          "filen"
        ]
      );
    };
}
