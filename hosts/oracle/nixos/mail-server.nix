{ config, pkgs, ... }:
{

  imports = [
    (builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-24.05/nixos-mailserver-nixos-23.05.tar.gz";
      sha256 = "sha256:0clvw4622mqzk1aqw1qn6shl9pai097q62mq1ibzscnjayhp278b";
    })
  ];

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
  # security.acme.acceptTerms = true;
  # security.acme.defaults.email = "security@${config.globals.domain_name}";
  #


  services.roundcube = {
    enable = true;
    # this is the url of the vhost, not necessarily the same as the fqdn of
    # the mailserver
    hostName = "webmail.naresh.world";
    extraConfig = ''
      # starttls needed for authentication, so the fqdn required to match
      # the certificate
      $config['smtp_server'] = "tls://${config.mailserver.fqdn}";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
    '';
  };

  # services.nginx.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}

