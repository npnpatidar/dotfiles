{ config, ... }:
let
  domain = config.globals.domain_name;
in
{
  services.freshrss = {
    enable = true;
    baseUrl = "https://freshrss.${domain}";
    defaultUser = "${config.globals.default_user}";
    passwordFile = config.age.secrets.freshrss_password.path;
    virtualHost = "freshrss.${domain}";
  };

  services.nginx = {
    virtualHosts."freshrss.${domain}" = {
      enableACME = true;
      forceSSL = true;
    };
  };
}
