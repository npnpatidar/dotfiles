{ config, lib, pkgs, ... }:

let mountdir = "${config.home.homeDirectory}/Data/megaCrypt";
in
{
  systemd.user = {
    services.rclone-mount = {
      Unit = {
        Description = "mount cloud using rclone ";
        After = [ "network-online.target" ];
      };
      Install.WantedBy = [ "multi-user.target" ];
      Service = {
        ExecStartPre = "/run/current-system/sw/bin/mkdir -p ${mountdir}";
        ExecStart = ''
          ${pkgs.rclone}/bin/rclone mount megaCrypt: ${mountdir} \
              --dir-cache-time 48h \
              --vfs-cache-mode full \
              --vfs-cache-max-age 48h \
              --vfs-read-chunk-size 10M \
              --vfs-read-chunk-size-limit 512M \
              --no-modtime \
              --buffer-size 512M
        '';
        ExecStop = "/run/wrappers/bin/fusermount -u ${mountdir}";
        Type = "notify";
        Restart = "always";
        RestartSec = "10s";
        Environment = [ "PATH=/run/wrappers/bin/" ];
      };
    };
  };
}
