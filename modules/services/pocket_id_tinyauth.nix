_: {
  flake.nixosModules.pocket_id_tinyauth =
    {
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.systemConstants) domain_name;
      inherit (config.sops.secrets) pocket-id-static-api-key;
      clientSecretsDir = "/var/lib/oidc-client-secrets";
      pocketIdUrl = "http://127.0.0.1:1411";
      idUrl = "https://id.${domain_name}";
      ssoUrl = "https://sso.${domain_name}";

      curl = "${pkgs.curl}/bin/curl";

      seedScript = pkgs.writeShellScript "pocket-id-seed-clients" ''
        set -euo pipefail
        mkdir -p -m 711 "${clientSecretsDir}"
        chmod 711 "${clientSecretsDir}"

        # Carry the admin API key in a root-only curl config file so the secret
        # never lands in a process argv (visible to other local users via /proc).
        umask 077
        api_cfg="$(mktemp)"
        trap 'rm -f "$api_cfg"' EXIT
        {
          printf 'header = "X-API-Key: '
          cat "${pocket-id-static-api-key.path}" | tr -d '\n'
          printf '"\n'
        } > "$api_cfg"

        wait_for_pocket_id() {
          for i in $(seq 1 30); do
          if ${curl} -sf -K "$api_cfg" -o /dev/null "${pocketIdUrl}/api/oidc/clients"; then
              return 0
            fi
            sleep 2
          done
          echo "Pocket ID not ready after 60s" >&2
          return 1
        }

        # Returns 0 if the given secret authenticates against Pocket ID's token
        # endpoint. Client authentication is verified before the grant type or
        # code is inspected, so a dummy code suffices: 401 = invalid_client
        # (bad secret); anything else (typically 400 invalid_grant) = valid.
        # A curl failure (Pocket ID briefly unreachable) is treated as valid so
        # a blip never triggers an unnecessary rotation.
        secret_is_valid() {
          local id="$1"
          local secret="$2"
          local callback_url="$3"
          local status
          status=$(${curl} -s -o /dev/null -w '%{http_code}' -X POST \
            "${pocketIdUrl}/api/oidc/token" \
            -H "Content-Type: application/x-www-form-urlencoded" \
            --data-urlencode "grant_type=authorization_code" \
            --data-urlencode "client_id=$id" \
            --data-urlencode "client_secret=$secret" \
            --data-urlencode "code=seed-health-check" \
            --data-urlencode "redirect_uri=$callback_url") || {
            echo "Health check for $id failed (curl error), assuming secret valid" >&2
            return 0
          }
          [ "$status" != "401" ]
        }

        # $4 = the group allowed to read the resulting secret file
        # $5 = the OIDC callback URL used to sanity-check the secret
        create_client() {
          local id="$1"
          local name="$2"
          local urls="$3"
          local group="$4"
          local callback_url="$5"
          local secret_file="${clientSecretsDir}/$id"

          # Ensure the client exists in Pocket ID. This heals the case where the
          # local secret file survived but Pocket ID's database was recreated.
          # (GET /api/oidc/clients returns {"data": [...], "pagination": ...})
          if ! ${curl} -sf -K "$api_cfg" "${pocketIdUrl}/api/oidc/clients" \
            | ${pkgs.jq}/bin/jq -e --arg id "$id" 'any(.data[]; .id == $id)' > /dev/null; then
            ${curl} -sf -K "$api_cfg" -X POST "${pocketIdUrl}/api/oidc/clients" \
              -H "Content-Type: application/json" \
              -d "{\"id\":\"$id\",\"name\":\"$name\",\"callbackURLs\":$urls}" \
              || echo "Client $id could not be created (may already exist) - continuing"
          fi

          # Reuse the on-disk secret when it still authenticates against Pocket
          # ID; rotate it when missing or stale. Pocket ID never returns the
          # stored secret, so rotation is the only way to (re)obtain one.
          if [ -f "$secret_file" ]; then
            local existing
            existing="$(cat "$secret_file")"
            if secret_is_valid "$id" "$existing" "$callback_url"; then
              echo "Client $id secret already valid, skipping"
              return 0
            fi
            echo "Client $id secret is stale, rotating"
          fi

          secret=$(${curl} -sf -K "$api_cfg" -X POST "${pocketIdUrl}/api/oidc/clients/$id/secret" \
            | ${pkgs.jq}/bin/jq -r '.secret') || {
            echo "Failed to rotate secret for $id" >&2
            return 1
          }

          if [ -z "$secret" ] || [ "$secret" = "null" ]; then
            echo "Obtained an empty/invalid secret for $id" >&2
            return 1
          fi

          printf '%s' "$secret" > "$secret_file"
          chown root:"$group" "$secret_file"
          chmod 640 "$secret_file"
          echo "Provisioned OIDC client secret: $id"
        }

        wait_for_pocket_id

        create_client "tinyauth" "Tinyauth" \
          '["${ssoUrl}/api/oauth/callback/pocketid"]' "tinyauth" \
          "${ssoUrl}/api/oauth/callback/pocketid"

        create_client "gitea" "Gitea" \
          '["https://git.${domain_name}/user/oauth2/pocket-id/callback"]' "gitea" \
          "https://git.${domain_name}/user/oauth2/pocket-id/callback"

        create_client "karakeep" "Karakeep" \
          '["https://karakeep.${domain_name}/api/auth/callback/custom"]' "karakeep" \
          "https://karakeep.${domain_name}/api/auth/callback/custom"

        # Write per-service env files with client secrets
        if [ -f "${clientSecretsDir}/karakeep" ]; then
          echo "OAUTH_CLIENT_SECRET=$(cat ${clientSecretsDir}/karakeep)" > "${clientSecretsDir}/karakeep-env"
          chown root:karakeep "${clientSecretsDir}/karakeep-env"
          chmod 640 "${clientSecretsDir}/karakeep-env"
        fi
      '';

    in
    {
      sops.secrets = {
        pocket-id-encryption-key = {
          sopsFile = ../../secrets/alma.yaml;
          mode = "0770";
          owner = "pocket-id";
          group = "pocket-id";
        };
        pocket-id-static-api-key = {
          sopsFile = ../../secrets/alma.yaml;
          mode = "0770";
          owner = "pocket-id";
          group = "pocket-id";
        };
        pocket-id-smtp-password = {
          sopsFile = ../../secrets/alma.yaml;
          mode = "0770";
          owner = "pocket-id";
          group = "pocket-id";
        };
        tinyauth-env = {
          sopsFile = ../../secrets/alma.yaml;
          mode = "0770";
          owner = "tinyauth";
          group = "tinyauth";
        };
      };

      services = {
        oink.domains = [
          {
            domain = "${domain_name}";
            subdomain = "sso";
          }
          {
            domain = "${domain_name}";
            subdomain = "id";
          }
        ];

        pocket-id = {
          enable = true;
          settings = {
            APP_URL = idUrl;
            HOST = "127.0.0.1";
            TRUST_PROXY = true;
            ANALYTICS_DISABLED = true;
            UI_CONFIG_DISABLED = true;
            # "Remember me": keep the Pocket ID session alive for 30 days so the
            # OIDC authorize step never requires re-entering credentials.
            SESSION_DURATION = "43200"; # 30 days (minutes)

            SMTP_HOST = "mail.${domain_name}";
            SMTP_PORT = 465;
            SMTP_TLS = "tls";
            SMTP_FROM = "naresh@${domain_name}";
            SMTP_USER = "naresh@${domain_name}";

            EMAIL_LOGIN_NOTIFICATION_ENABLED = true;
            EMAIL_API_KEY_EXPIRATION_ENABLED = true;
            EMAIL_VERIFICATION_ENABLED = true;
          };
          credentials = {
            STATIC_API_KEY = pocket-id-static-api-key.path;
            ENCRYPTION_KEY = config.sops.secrets.pocket-id-encryption-key.path;
            SMTP_PASSWORD = config.sops.secrets.pocket-id-smtp-password.path;
          };
        };

        tinyauth = {
          enable = true;
          settings = {
            APPURL = ssoUrl;
            SERVER_ADDRESS = "127.0.0.1";
            SERVER_PORT = 3009;
            ANALYTICS_ENABLED = false;
            RESOURCES_ENABLED = false;
            # "Remember me": persist the SSO session cookie for 30 days (seconds)
            # instead of the 24h default, so re-visits skip the login flow entirely.
            AUTH_SESSIONEXPIRY = "2592000";
            OAUTH_PROVIDERS_POCKETID_NAME = "Pocket ID";
            OAUTH_PROVIDERS_POCKETID_CLIENTID = "tinyauth";
            OAUTH_PROVIDERS_POCKETID_CLIENTSECRETFILE = "${clientSecretsDir}/tinyauth";
            OAUTH_PROVIDERS_POCKETID_SCOPES = "openid,profile,email";
            OAUTH_PROVIDERS_POCKETID_AUTHURL = "${idUrl}/authorize";
            OAUTH_PROVIDERS_POCKETID_TOKENURL = "${idUrl}/api/oidc/token";
            OAUTH_PROVIDERS_POCKETID_USERINFOURL = "${idUrl}/api/oidc/userinfo";
            OAUTH_PROVIDERS_POCKETID_REDIRECTURL = "${ssoUrl}/api/oauth/callback/pocketid";
          };
          environmentFile = config.sops.secrets.tinyauth-env.path;
        };

        nginx.virtualHosts = {
          "sso.${domain_name}" = {
            enableACME = true;
            forceSSL = true;
            locations."/" = {
              proxyPass = "http://127.0.0.1:3009";
              proxyWebsockets = true;
            };
          };

          "id.${domain_name}" = {
            enableACME = true;
            forceSSL = true;
            locations."/" = {
              proxyPass = "http://127.0.0.1:1411";
              proxyWebsockets = true;
            };
          };
        };
      };

      systemd.services.pocket-id-seed = {
        description = "Seed Pocket ID with OIDC clients";
        after = [
          "pocket-id.service"
        ];
        wants = [ "pocket-id.service" ];
        wantedBy = [ "multi-user.target" ];
        before = [ "tinyauth.service" ];
        startLimitBurst = 30;
        startLimitIntervalSec = 600;
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${seedScript}";
          RemainAfterExit = true;
          Restart = "on-failure";
          RestartSec = "10s";

          # Sandboxing: the seed only needs loopback network access and write
          # access to its own secrets dir; keep the rest of the system read-only
          # to it and hide other processes (defence in depth for the admin key).
          NoNewPrivileges = true;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectHome = true;
          ProtectSystem = "strict";
          ReadWritePaths = [ "/var/lib/oidc-client-secrets" ];
          ProtectProc = "invisible";
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectKernelLogs = true;
          ProtectControlGroups = true;
          ProtectClock = true;
          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];
          RestrictNamespaces = true;
          RestrictSUIDSGID = true;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          SystemCallArchitectures = "native";
        };
      };

      systemd.services.tinyauth = {
        after = [ "pocket-id-seed.service" ];
        requires = [ "pocket-id-seed.service" ];
      };
    };
}
