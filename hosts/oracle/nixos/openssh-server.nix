{ ... }:
{


  services.openssh = {
    enable = true;
    ports = [ 46587 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [ "naresh" "git" ];
    };
    extraConfig = "MaxAuthTries 10";
  };

}
