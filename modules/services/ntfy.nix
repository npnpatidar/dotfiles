# ntfy — self-hosted push notification server.
# Served at https://ntfy.<domain> via nginx (TLS terminates there; ntfy itself
# listens on loopback only). Private instance: ntfy's own user database gates
# every read/write, so the mobile and desktop apps work through any proxy.
#
# The pre-provisioned admin user's bcrypt hash is passed via NTFY_AUTH_USERS in
# a sops secret rather than `settings`, because `settings` is rendered into
# /nix/store/server.yml which is world-readable.
_: {
  flake.nixosModules.ntfy =
    { config, lib, ... }:
    let
      dataDir = "/mnt/filen/Alma/services/ntfy";
    in
    {
      sops.secrets.ntfy_environment_file = {
        sopsFile = ../../secrets/alma.yaml;
      };

      services = {
        oink.domains = [
          {
            domain = "${config.systemConstants.domain_name}";
            subdomain = "ntfy";
          }
        ];

        ntfy-sh = {
          enable = true;

          # Anonymous access is denied outright; only the provisioned admin user
          # (and any ACL entries) can read or publish.
          settings = {
            base-url = "https://ntfy.${config.systemConstants.domain_name}";
            listen-http = "127.0.0.1:2586";
            behind-proxy = true;
            auth-default-access = "deny-all";
            enable-login = true;

            auth-file = "${dataDir}/user.db";
            cache-file = "${dataDir}/cache.db";
            web-push-file = "${dataDir}/webpush.db";
            attachment-cache-dir = "${dataDir}/attachments";

            # Attachments live on the /mnt/filen share, so keep the on-disk cap
            # well below the ~478G free there but bounded all the same.
            attachment-total-size-limit = "2G";
            attachment-file-size-limit = "15M";
          };

          environmentFile = config.sops.secrets.ntfy_environment_file.path;
        };

        nginx.virtualHosts."ntfy.${config.systemConstants.domain_name}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:2586";
            proxyWebsockets = true;
            # ntfy streams responses; buffering breaks the web app and long-lived
            # subscriptions. Stream request bodies too so large attachments aren't
            # spooled to disk by nginx first. 3m timeouts match upstream's
            # documented proxy config for long-polling connections.
            extraConfig = ''
              proxy_buffering off;
              proxy_request_buffering off;
              proxy_connect_timeout 3m;
              proxy_send_timeout 3m;
              proxy_read_timeout 3m;
              client_max_body_size 0;
            '';
          };
        };
      };

      # The upstream module is DynamicUser-only (its user/group options were
      # removed), which cannot own files on the persistent /mnt/filen share.
      # Define our own static service account instead.
      users.users.ntfy = {
        isSystemUser = true;
        group = "ntfy";
        description = "ntfy push notification server";
      };
      users.groups.ntfy = { };

      systemd.services.ntfy-sh.serviceConfig = {
        # NixOS drops User=/Group= from the unit when it believes DynamicUser
        # is enabled, so both must be restated here or the service ends up
        # running as root.
        DynamicUser = lib.mkForce false;
        User = "ntfy";
        Group = "ntfy";
        # ProtectSystem=full mounts / read-only; the API dirs (/var, /run) are
        # exempt but /mnt is not, so the data dir must be allow-listed or ntfy
        # cannot write its databases there.
        ReadWritePaths = [ dataDir ];
      };

      systemd.tmpfiles.rules = [ "d ${dataDir} 0755 ntfy ntfy -" ];
    };
}
