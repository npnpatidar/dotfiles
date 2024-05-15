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
    fqdn = "mail.naresh.world";
    domains = [ "naresh.world" ];

    loginAccounts = {
      "naresh@naresh.world" = {
        hashedPasswordFile = config.age.secrets."hashedstandard".path;
        aliases = [ "postmaster@naresh.world" ];
      };
      # "user2@example.com" = { ... };
    };

    certificateScheme = "acme-nginx";
  };
  # security.acme.acceptTerms = true;
  # security.acme.defaults.email = "security@naresh.world";
}

