_: {
  flake.nixosModules.radicale = { config, lib, ... }: {
    services = {
      oink.domains = [
        {
          domain = "${config.systemConstants.domain_name}";
          subdomain = "cal";
        }
      ];

      radicale = {
        enable = true;
        settings.auth = {
          type = "imap";
          imap_security = "tls";
          imap_host = "${config.mailserver.fqdn}:993";
        };
      };

      nginx.virtualHosts."cal.${config.systemConstants.domain_name}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:5232/";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header  X-Script-Name " ";
            proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass_header Authorization;
          '';
        };
      };
    };

    systemd.services.radicale.serviceConfig = {
      PrivateNetwork = false;
      IPAddressDeny = lib.mkForce null;
    };
  };
}
