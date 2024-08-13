{ config, pkgs, inputs, lib, ... }:
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
        aliases = [ "@${config.globals.domain_name}" ];
        catchAll = [ "${config.globals.domain_name}" ];
      };
      # "user2@example.com" = { ... };
    };

    fullTextSearch = {
      enable = true;
      enforced = "body";
      indexAttachments = true;
      memoryLimit = 512;
    };
    indexDir = "/var/lib/dovecot/indices";
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
    package = pkgs.roundcube.withPlugins (
      plugins: [
        plugins.carddav
        plugins.contextmenu
        plugins.custom_from
        plugins.persistent_login
        plugins.thunderbird_labels
      ]
    );
    plugins = [
      "attachment_reminder" # Roundcube internal plugin
      "carddav"
      "contextmenu"
      "custom_from"
      "managesieve" # Roundcube internal plugin
      "newmail_notifier" # Roundcube internal plugin
      "persistent_login"
      "thunderbird_labels"
      "zipdownload" # Roundcube internal plugin
    ];
  };

}

