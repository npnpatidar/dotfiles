{ lib, pkgs, config, ... }:
let
  mkRcloneService = environment:
    lib.nameValuePair "rclone-${environment}" {
      script = ''
        ${pkgs.rclone}/bin/rclone sync --copy-links "/" ${environment}:/oracle_backup --verbose --create-empty-src-dirs  --check-first --config="/etc/rclone/rclone.conf" --filter-from="/etc/rclone/${environment}-filter.text"
      '';
      serviceConfig = {
        User = "root";
        Group = "wheel";
      };
    };

  mkSyncTimer = environment:
    lib.nameValuePair "rclone-${environment}" {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        # 5 minutes after boot
        # OnBootSec = "2m";
        # 5 minutes after last finished
        # OnUnitInactiveSec = "5m";

        Unit = "rclone-${environment}.service";
      };
    };

in
{
  systemd.services = builtins.listToAttrs
    (map mkRcloneService [
      # "alternate"
      "alternateCrypt"
    ]);

  systemd.timers = builtins.listToAttrs
    (map mkSyncTimer [
      # "alternate"
      "alternateCrypt"
    ]);

  environment.etc."rclone/alternateCrypt-filter.text".source =
    pkgs.writeText "alternateCrypt-filter.text" ''
      + /var/lib/bitwarden_rs/** 
      - *
    '';
  environment.etc."rclone/rclone.conf".source = config.age.secrets."rclone_config".path;
  # rclone bisync naresh.alternate: ~/Data/naresh.alternate --resync --filter-from ~/.config/rclone/naresh.alternate.txt 
  # for the first time and similarly for other services untill this command is not successful service won't run
  # + Normal/** to inclue files 
  # - rcloneCrypt/** to exclude files
  # you can check the status of the service using systemctl --user status rclone-naresh.alternate.service
}


