_: {
  flake.nixosModules.gitea =
    {
      config,
      pkgs,
      ...
    }:
    {
      sops.secrets.gitea_action_runner_token = {
        sopsFile = ../../secrets/alma.yaml;
      };

      services = {
        oink.domains = [
          {
            domain = "${config.systemConstants.domain_name}";
            subdomain = "git";
          }
        ];

        gitea = {
          enable = true;
          settings = {
            mailer = {
              ENABLED = false;
              PROTOCOL = "sendmail";
              SENDMAIL_PATH = "/run/wrappers/bin/sendmail";
            };
            server = {
              SSH_PORT = config.systemConstants.ssh_port;
              HTTP_PORT = 5654;
              DOMAIN = "git.${config.systemConstants.domain_name}";
              ROOT_URL = "https://git.${config.systemConstants.domain_name}";
            };
            repository = {
              DEFAULT_PUSH_CREATE_PRIVATE = true;
              ENABLE_PUSH_CREATE_USER = true;
              DEFAULT_PRIVATE = true;
            };
            service = {
              DISABLE_REGISTRATION = true;
            };
            actions = {
              enabled = true;
            };
          };
        };

        nginx.virtualHosts."git.${config.systemConstants.domain_name}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:5654";
          };
        };

        gitea-actions-runner = {
          instances.default = {
            enable = false;
            url = "https://git.${config.systemConstants.domain_name}";
            tokenFile = config.sops.secrets.gitea_action_runner_token.path;
            name = "whale";
            labels = [ "ubuntu-latest:docker://node:16-bullseye" ];
            settings = {
              capacity = 4;
            };
          };
        };
      };

      systemd.services.gitea-oidc-setup = {
        description = "Register Pocket ID OIDC auth source in Gitea";
        # Must complete BEFORE gitea starts: Gitea registers OAuth2 providers
        # (client id/secret) in memory at startup, so the DB must already hold
        # the current Pocket ID secret or the running process keeps a stale one.
        after = [
          "pocket-id-seed.service"
        ];
        requires = [
          "pocket-id-seed.service"
        ];
        before = [
          "gitea.service"
        ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          User = "gitea";
          Environment = [
            "GITEA_WORK_DIR=/var/lib/gitea"
            "GITEA_CUSTOM=/var/lib/gitea/custom"
          ];
        };
        script = ''
          GITEA="${pkgs.gitea}/bin/gitea"
          SECRET_FILE="/var/lib/oidc-client-secrets/gitea"
          DISCOVER_URL="https://id.${config.systemConstants.domain_name}/.well-known/openid-configuration"

          SECRET="$(cat "$SECRET_FILE")"

          # Auth source ID, independent of the table layout (bordered or not).
          AUTH_ID=$($GITEA admin auth list 2>/dev/null \
            | grep "pocket-id" | grep -oE '[0-9]+' | head -1)

          if [ -z "$AUTH_ID" ]; then
            $GITEA admin auth add-oauth \
              --name "pocket-id" \
              --provider openidConnect \
              --key gitea \
              --secret "$SECRET" \
              --auto-discover-url "$DISCOVER_URL" \
              --scopes "openid email profile"
            AUTH_ID=$($GITEA admin auth list 2>/dev/null \
              | grep "pocket-id" | grep -oE '[0-9]+' | head -1)
          fi

          if [ -z "$AUTH_ID" ]; then
            echo "Failed to find or create the pocket-id auth source" >&2
            exit 1
          fi

          # Declaratively re-apply the full auth source config (idempotent).
          # This heals any drift between Gitea's stored secret/options and the
          # client provisioned in Pocket ID without manual intervention.
          $GITEA admin auth update-oauth \
            --id "$AUTH_ID" \
            --name "pocket-id" \
            --provider openidConnect \
            --key gitea \
            --secret "$SECRET" \
            --auto-discover-url "$DISCOVER_URL" \
            --scopes "openid email profile"
        '';
      };
    };
}
