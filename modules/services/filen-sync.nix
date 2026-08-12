_: {
  flake.nixosModules.filen-sync =
    { config, pkgs, ... }:
    let
      syncPairsJson = pkgs.writeText "syncPairs.json" ''
        [
          { "local": "/var/lib/paperless", "remote": "/Alma/services/paperless", "syncMode": "localToCloud" },
          { "local": "/var/lib/radicale", "remote": "/Alma/services/radicale", "syncMode": "localToCloud" },
          { "local": "/var/lib/redis-rspamd", "remote": "/Alma/services/mail-server/redis-rspamd", "syncMode": "localToCloud" },
          { "local": "/var/dkim", "remote": "/Alma/services/mail-server/dkim", "syncMode": "localToCloud" }
        ]
      '';
    in
    {
      sops.secrets.filen_cli_auth_config = {
        sopsFile = ../../secrets/alma.yaml;
        mode = "0600";
        owner = "${config.systemConstants.default_user}";
        path = "${config.systemConstants.home_directory}/.config/filen-cli/.filen-cli-auth-config";
      };
      sops.secrets.filen_cli_auth_config_root = {
        sopsFile = ../../secrets/alma.yaml;
        path = "/root/.config/filen-cli/.filen-cli-auth-config";
      };

      environment.systemPackages = [ pkgs.filen-cli ];

      systemd.services.filen-sync = {
        description = "Filen Drive Continuous Sync";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        preStart = ''
          mkdir -p /root/.config/filen-cli
          ln -sf ${syncPairsJson} /root/.config/filen-cli/syncPairs.json
        '';
        serviceConfig = {
          ExecStart = "${pkgs.filen-cli}/bin/filen sync --continuous";
          User = "root";
          Environment = "HOME=/root";
          Restart = "always";
          RestartSec = "10s";
        };
      };
    };
}
