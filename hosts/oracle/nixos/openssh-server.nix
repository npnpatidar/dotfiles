{ config, ... }:
{


  services.openssh = {
    enable = true;
    ports = [ 46587 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [ "${config.globals.default_user}" "${config.services.gitea.user}" ];
    };
    extraConfig = "MaxAuthTries 10";
  };



}
