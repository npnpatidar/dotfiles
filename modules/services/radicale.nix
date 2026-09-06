_: {
  flake.nixosModules.radicale =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # Patch radicale's IMAP auth to skip TLS cert verification for localhost.
      # The ACME cert is for mail.<domain>, not 127.0.0.1, so verification
      # fails when authenticating against the local Dovecot on 127.0.0.1:993.
      radicalePatched = pkgs.radicale.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace radicale/auth/imap.py \
            --replace 'ssl.create_default_context()' 'ssl._create_unverified_context()'
        '';
      });
    in
    {
      services = {
        oink.domains = [
          {
            domain = "${config.systemConstants.domain_name}";
            subdomain = "cal";
          }
        ];

        radicale = {
          enable = true;
          package = radicalePatched;
          settings.auth = {
            type = "imap";
            imap_security = "tls";
            imap_host = "127.0.0.1:993";
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
