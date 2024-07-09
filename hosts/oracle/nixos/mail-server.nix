{ config, pkgs, ... }:
{

  imports = [
    (builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-23.05/nixos-mailserver-nixos-23.05.tar.gz";
      # sha256 = "0000000000000000000000000000000000000000000000000000";
      sha256 = "sha256:1ngil2shzkf61qxiqw11awyl81cr7ks2kv3r3k243zz7v2xakm5c";
    })
  ];

  mailserver = {
    enable = true;
    fqdn = "mail.${config.globals.domain_name}";
    domains = [ "${config.globals.domain_name}" ];

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

