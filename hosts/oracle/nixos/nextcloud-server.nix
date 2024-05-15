{ config, pkgs, ... }: {
  age.secrets.nextcloud_admin_password = {
    file = ../../../secrets/nextcloud_admin_password.age;
    mode = "770";
    owner = "nextcloud";
    group = "nextcloud";
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28;
    hostName = "nextcloud.naresh.world";
    https = true;
    config = {
      adminpassFile = config.age.secrets."nextcloud_admin_password".path;
    };
  };
  services.nginx = {
    virtualHosts."nextcloud.naresh.world" = {
      forceSSL = true;
      enableACME = true;
    };
  };
}
