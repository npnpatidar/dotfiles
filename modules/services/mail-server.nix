_: {
  flake.nixosModules.mail-server =
    {
      config,
      lib,
      pkgs,
      inputs,
      ...
    }:
    let
      domain = config.systemConstants.domain_name;
      # MTA-STS policy: forces inbound TLS. Served from
      # https://mta-sts.<domain>/.well-known/mta-sts.txt; publish the TXT
      # record _mta-sts.<domain> = "v=STSv1; id=20260807" at the registrar.
      mtaStsPolicy = pkgs.writeText "mta-sts.txt" ''
        version: STSv1
        mode: enforce
        mx: mail.${domain}
        max_age: 604800
      '';
    in
    {
      imports = [ inputs.simple-nixos-mailserver.nixosModules.default ];

      sops.secrets.mail_password = {
        sopsFile = ../../secrets/alma.yaml;
      };

      security.acme.certs.${config.mailserver.fqdn} = {
        webroot = "/var/lib/acme/acme-challenge";
      };

      mailserver = {
        enable = true;
        fqdn = "mail.${domain}";
        domains = [ "${domain}" ];
        openFirewall = true;
        localDnsResolver = false;
        stateVersion = 5;
        # Standard submission (STARTTLS) on 587 in addition to 465.
        enableSubmission = true;
        storage.path = "/mnt/filen/Alma/services/mail-server/vmail";
        x509.useACMEHost = config.mailserver.fqdn;
        accounts."naresh@${domain}" = {
          hashedPasswordFile = config.sops.secrets."mail_password".path;
          aliases = [ "@${domain}" ];
          catchAll = [ "${domain}" ];
        };
        fullTextSearch = {
          enable = true;
          autoIndex = true;
          memoryLimit = 512;
        };
        indexDir = "/mnt/filen/Alma/services/mail-server/dovecot/indices";
        enableManageSieve = true;
        # Rotate the DKIM key to 2048-bit RSA (the current one is 1024-bit).
        # A new selector is used so the old key keeps working during the DNS
        # transition; publish /var/dkim/rajedu.in.mail2.txt as a TXT record
        # on mail2._domainkey.${domain}, then drop mail._domainkey after a
        # few days.
        dkim = {
          domains.${domain}.selectors = {
            mail2 = {
              keyLength = 2048;
            };
          };
        };
      };

      services = {
        # rspamd lookups (RBLs, DMARC, maps) go straight to unfiltered public
        # resolvers instead of the system chain (Tailscale MagicDNS -> AdGuard
        # Home), so a tailscale/AdGuard hiccup can't stall mail processing.
        rspamd.locals."dns.conf".text = ''
          nameservers = [ "9.9.9.9:53" "1.1.1.1:53" ];
        '';

        oink.domains = [
          {
            domain = "${domain}";
            subdomain = "mta-sts";
          }
        ];

        nginx.virtualHosts."mta-sts.${domain}" = {
          enableACME = true;
          forceSSL = true;
          enableTinyauth = false;
          locations."= /.well-known/mta-sts.txt" = {
            alias = "${mtaStsPolicy}";
          };
        };

        roundcube = {
          enable = true;
          hostName = "webmail.${config.systemConstants.domain_name}";
          extraConfig = ''
            $config['smtp_server'] = "tls://${config.mailserver.fqdn}";
            $config['smtp_user'] = "%u";
            $config['smtp_pass'] = "%p";
            $config['imap_host'] = "ssl://${config.mailserver.fqdn}:993";
          '';
          package = pkgs.roundcube.withPlugins (plugins: [
            plugins.carddav
            plugins.contextmenu
            plugins.custom_from
            plugins.persistent_login
            plugins.thunderbird_labels
          ]);
          plugins = [
            "attachment_reminder"
            "carddav"
            "contextmenu"
            "custom_from"
            "managesieve"
            "newmail_notifier"
            "persistent_login"
            "thunderbird_labels"
            "zipdownload"
          ];
        };
      };
      # phpfpm hardcodes WatchdogSec=15 for every pool; with vmail on the rclone
      # FUSE mount, transient IMAP/DB stalls exceed 15s and systemd kills the
      # FPM ("busy watchdog" restarts). Disable the watchdog for roundcube only:
      # Restart=always still recovers from real crashes, and a brief stall no
      # longer takes webmail down.
      systemd.services."phpfpm-roundcube".serviceConfig.WatchdogSec = lib.mkForce 0;
    };
}
