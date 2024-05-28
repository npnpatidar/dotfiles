{ config, pkgs, inputs, ... }: {
  services.writefreely = {
    enable = true;
    acme.enable = true;
    nginx.enable = true;
    nginx.forceSSL = true;
    host = "blog.naresh.world";
    admin.name = "naresh";
    admin.initialPasswordFile = config.age.secrets.standard.path;
    settings.server.port = 7898;
    settings.app = {
      site_name = "Naresh's blog";
      single_user = true;
    };
  };

  # age = {
  #   secrets.standard = {
  #     file = ../../../secrets/standard.age;
  #     mode = "400";
  #     owner = "writefreely";
  #     group = "writefreely";
  #   };
  # };


}
