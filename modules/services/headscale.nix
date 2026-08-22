_: {
  flake.nixosModules.headscale =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (config.systemConstants) domain_name;
      clientSecretsDir = "/var/lib/oidc-client-secrets";

      format = pkgs.formats.yaml { };
      headscaleConfigForPlane = format.generate "headscale-for-plane.yml" (
        lib.recursiveUpdate config.services.headscale.settings {
          tls_cert_path = "/dev/null";
          tls_key_path = "/dev/null";
          policy.path = "/dev/null";
        }
      );
    in
    {
      sops.secrets.headscale_api_key = {
        sopsFile = ../../secrets/alma.yaml;
        owner = "headscale";
        group = "headscale";
      };
      sops.secrets.headscale_cookie_secret = {
        sopsFile = ../../secrets/alma.yaml;
        owner = "headscale";
        group = "headscale";
      };

      services = {
        oink.domains = [
          {
            domain = "${domain_name}";
            subdomain = "headscale";
          }
        ];

        headscale = {
          enable = true;
          address = "127.0.0.1";
          port = 8097;
          settings = {
            server_url = "https://headscale.${domain_name}";
            disable_check_updates = true;
            derp.server = {
              enabled = false;
            };
            prefixes = {
              v4 = "100.64.0.0/24";
              v6 = "fd7a:115c:a1e0::/48";
              allocation = "sequential";
            };
            dns = {
              base_domain = "n";
              override_local_dns = true;
              magic_dns = true;
              domains = [ "${domain_name}" ];
              nameservers.global = [ "100.64.0.2" ];
              extra_records = [ ];
            };
            oidc = {
              issuer = "https://id.${domain_name}";
              client_id = "headscale";
              client_secret_path = "${clientSecretsDir}/headscale";
            };
          };
        };

        headplane = {
          enable = true;
          settings = {
            server = {
              host = "127.0.0.1";
              port = 3000;
              base_url = "https://headscale.${domain_name}";
              cookie_secret_path = config.sops.secrets.headscale_cookie_secret.path;
              cookie_secure = true;
            };
            headscale = {
              url = "http://127.0.0.1:8097";
              public_url = "https://headscale.${domain_name}";
              config_path = "${headscaleConfigForPlane}";
              config_strict = true;
              api_key_path = config.sops.secrets.headscale_api_key.path;
            };
            oidc = {
              issuer = "https://id.${domain_name}";
              client_id = "headplane";
              client_secret_path = "${clientSecretsDir}/headplane";
              disable_api_key_login = true;
              token_endpoint_auth_method = "client_secret_basic";
            };
          };
        };

        nginx = {
          enable = true;
          recommendedProxySettings = true;
          virtualHosts."headscale.${domain_name}" = {
            forceSSL = true;
            enableACME = true;
            locations."/" = {
              proxyPass = "http://127.0.0.1:8097";
              proxyWebsockets = true;
            };
            locations."/admin" = {
              proxyPass = "http://127.0.0.1:3000";
              proxyWebsockets = true;
            };
          };
        };
      };

      systemd.services = {
        # Don't start headscale until its OIDC client secret has been seeded
        headscale = {
          after = [ "pocket-id-seed.service" ];
          requires = [ "pocket-id-seed.service" ];
        };
      };
    };
}
