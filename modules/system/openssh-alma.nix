_: {
  flake.nixosModules.openssh-alma = { config, ... }: {
    services.openssh = {
      settings = {
        PermitRootLogin = "no";
        AllowUsers = [
          "${config.systemConstants.default_user}"
          "${config.services.gitea.user}"
        ];
        MaxAuthTries = 4;
      };
      ports = [ 46587 ];
      allowSFTP = true;
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };

    services.fail2ban = {
      enable = true;
      jails = {
        # Public SSH gets constant brute-force probes; ban aggressively.
        sshd = {
          filter = "sshd";
          settings = {
            logpath = "sshd.service"; # journald unit (backend = systemd)
            maxretry = 4;
            findtime = "1h";
            bantime = "6h";
          };
        };
        # IMAP/SMTP are publicly reachable and get brute-forced (observed
        # probes for info@/billing@/admin@/... against 993 from the internet).
        dovecot = {
          filter = "dovecot";
          settings = {
            logpath = "dovecot.service"; # journald unit (backend = systemd)
            maxretry = 3;
            findtime = "6h";
            bantime = "6h";
          };
        };
        postfix-sasl = {
          # this fail2ban build doesn't ship a postfix-sasl.conf filter, so use
          # the postfix filter (aggressive mode covers SASL auth failures).
          # Note: the filter NAME must go in settings (top-level `filter` is
          # for writing filter-file content, not the jail's filter directive).
          settings = {
            filter = "postfix[mode=aggressive]";
            logpath = "postfix.service";
            maxretry = 3;
            findtime = "6h";
            bantime = "6h";
          };
        };
      };
    };
  };
}
