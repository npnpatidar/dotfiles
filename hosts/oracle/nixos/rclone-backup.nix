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
    ]) // {
    "rclone_config" = {
      wantedBy = [ "multi-user.target" ];
      script = ''
        #!/bin/sh
        cp /etc/rclone/rclone.conf ${config.globals.home_directory}/.config/rclone
        chown ${config.globals.default_user} ${config.globals.home_directory}/.config/rclone/rclone.conf
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };

  systemd.timers = builtins.listToAttrs
    (map mkSyncTimer [
      "koofrCrypt"
    ]);

  environment.etc = builtins.listToAttrs
    (map mkRcloneFilterFile [
      {
        remote_name = "koofrCrypt";
        filterFileText = ''
          + ${config.globals.data_directory}/.backups/vaultwarden/**
          + /var/lib/anki-sync-server/**
          + /var/lib/gitDaemon/**
          + /var/lib/nextcloud/data/naresh/files/**
          + /var/lib/gitea/repositories/**
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


