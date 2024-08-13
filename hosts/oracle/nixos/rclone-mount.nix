{ lib, config, pkgs, inputs, ... }:
let

  mkRcloneMount = remote_name:
    lib.nameValuePair "/mnt/${remote_name}" {
      device = "${remote_name}:";
      fsType = "rclone";
      options = [
        "rw"
        "allow_other"
        "_netdev"
        # "noauto"
        "x-systemd.automount"

        # rclone specific
        "env.PATH=/run/wrappers/bin" # for fusermount3
        "config=/etc/rclone/rclone.conf"
        "cache_dir=/tmp/remote/${remote_name}"
        "dir-cache-time 48h"
        "vfs-cache-mode full"
        "vfs-read-chunk-size 10M"
        "vfs-read-chunk-size-limit 512M"
        "no-modtime"
        "buffer-size 512M"
      ];
    };
in
{

  system.fsPackages = [ pkgs.rclone ];

  fileSystems = builtins.listToAttrs
    (map mkRcloneMount [
      "koofrCrypt"
      "megaCrypt"
      "npnpatidarCrypt"
      "naresh.alternateCrypt"
      "arebhaiCrypt"
      "mega"
    ]);
}
