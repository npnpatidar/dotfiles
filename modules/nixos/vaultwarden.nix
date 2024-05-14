{ pkgs, config, ... }: {
  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://vaultwarden.naresh.world";
      SIGNUPS_ALLOWED = false;
      ROCKET_PORT = 8222;
      rocketAddress = "127.0.0.1";
      rocketLog = "critical";
      disableIconDownload = false;
    };
  };


  systemd.timers."vault-backup" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      Unit = "vault-backup.service";
    };
  };

  systemd.services."vault-backup" = {
    script = ''
      #!/bin/sh

      # Set the script to exit immediately if any command fails
      set -e

      DATE=$(date +%Y-%m-%d)
      BACKUP_DIR=/home/naresh/Data/.backups/vaultwarden
      BACKUP_FILE=vaultwarden-$DATE.tar
      CONTAINER=vaultwarden
      VAULTWARDEN_DATA_DIR=/var/lib/bitwarden_rs/

      # create backups directory if it does not exist
      mkdir -p $BACKUP_DIR

      # Stop the container
      systemctl stop vaultwarden.service

      # Backup the vaultwarden data directory to the backup directory
      ${pkgs.gnutar}/bin/tar -cf "$BACKUP_DIR/$BACKUP_FILE" -C "$VAULTWARDEN_DATA_DIR" .

      # Restart the container
      systemctl start vaultwarden.service

      # To delete files older than 30 days
      # find $BACKUP_DIR/* -mtime +30 -exec rm {} \;


    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };



}
