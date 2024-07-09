{ config, pkgs, inputs, ... }:
{
  imports = [ inputs.simple-nixos-mailserver.nixosModule ];

  mailserver = {
    enable = true;
    fqdn = "mail.${config.globals.domain_name}";
    domains = [ "${config.globals.domain_name}" ];
    openFirewall = true;

    loginAccounts = {
      "naresh@${config.globals.domain_name}" = {
        hashedPasswordFile = config.age.secrets."hashedstandard".path;
        aliases = [ "postmaster@${config.globals.domain_name}" ];
      };
      # "user2@example.com" = { ... };
    };

    certificateScheme = "acme-nginx";
  };


  services.roundcube = {
    enable = true;
    hostName = "webmail.naresh.world";
    extraConfig = ''
      # starttls needed for authentication, so the fqdn required to match
      # the certificate
      $config['smtp_server'] = "tls://${config.mailserver.fqdn}";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
    '';
  };

}

