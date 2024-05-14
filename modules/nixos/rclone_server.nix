{ lib, pkgs, config, ... }:
let
  mkRcloneService = remote_name:
    lib.nameValuePair "rclone-${remote_name}" {
      script = ''
        ${pkgs.rclone}/bin/rclone sync --copy-links "/" ${remote_name}:/oracle_backup --verbose --create-empty-src-dirs  --check-first --config="/etc/rclone/rclone.conf" --filter-from="/etc/rclone/${remote_name}-filter.text"
      '';
      serviceConfig = {
        User = "root";
        Group = "wheel";
      };
    };

  mkSyncTimer = remote_name:
    lib.nameValuePair "rclone-${remote_name}" {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        # 5 minutes after boot
        # OnBootSec = "2m";
        # 5 minutes after last finished
        # OnUnitInactiveSec = "5m";

        Unit = "rclone-${remote_name}.service";
      };
    };

  mkRcloneFilterFile = { remote_name, filterFileText }:
    lib.nameValuePair "rclone/${remote_name}-filter.text" {
      source = pkgs.writeText "${remote_name}-filter.text" "${filterFileText}";
    };

in
{
  systemd.services = builtins.listToAttrs
    (map mkRcloneService [
      # "koofr"
      "koofrCrypt"
    ]);

  systemd.timers = builtins.listToAttrs
    (map mkSyncTimer [
      # "koofr"
      "koofrCrypt"
    ]);

  environment.etc = builtins.listToAttrs
    (map mkRcloneFilterFile [
      {
        remote_name = "koofrCrypt";
        filterFileText = ''
          + /var/lib/bitwarden_rs/** 
          - *
        '';
      }
    ]) // { "rclone/rclone.conf".source = config.age.secrets."rclone_config".path; };



  # rclone bisync naresh.alternate: ~/Data/naresh.alternate --resync --filter-from ~/.config/rclone/naresh.alternate.txt 
  # for the first time and similarly for other services untill this command is not successful service won't run
  # + Normal/** to inclue files 
  # - rcloneCrypt/** to exclude files
  # you can check the status of the service using systemctl --user status rclone-naresh.alternate.service
}


