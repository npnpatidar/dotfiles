{ config, ... }:
{


  services.openssh = {
    enable = true;
    ports = [ 46587 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [ "naresh" "gitea" ];
    };
    extraConfig = "MaxAuthTries 10";
  };



}
