_: {
  flake.nixosModules.rclone-mount-aspire7 = { config, ... }: {
    environment.etc."rclone.conf" = {
      source = config.sops.secrets.rclone_config.path;
    };

    systemd.services."vault-backup" = {
      wantedBy = [ "multi-user.target" ];
      script = "cp /etc/rclone.conf ${config.systemConstants.home_directory}/.config/rclone";
      serviceConfig = {
        Type = "oneshot";
        User = "${config.systemConstants.default_user}";
      };
    };
  };
}
