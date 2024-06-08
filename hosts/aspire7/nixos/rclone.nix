{ config, ... }: {
  age.secrets.rclone_config = {
    file = ../../../secrets/rclone_config.age;
    mode = "770";
    owner = "naresh";
    group = "users";
  };

  environment.etc."rclone.conf".source = config.age.secrets.rclone_config.path;


  systemd.services."vault-backup" = {

    wantedBy = [ "multi-user.target" ];
    script = ''
      #!/bin/sh
      cp /etc/rclone.conf /home/naresh/.config/rclone
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "naresh";
    };
  };


}
