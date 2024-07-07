{ config, pkgs, ... }:
let
  cfg = config.services.n8n;
  format = pkgs.formats.json { };
  configFile = format.generate "n8n.json" cfg.settings;
in
{
  nixpkgs.config.allowUnfree = true;
  # services.n8n.enable = true;


  systemd.services.n8n = {
    description = "N8N service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      # This folder must be writeable as the application is storing
      # its data in it, so the StateDirectory is a good choice
      N8N_USER_FOLDER = "/var/lib/n8n";
      HOME = "/var/lib/n8n";
      N8N_CONFIG_FILES = "${configFile}";
      WEBHOOK_URL = "https://n8n.naresh.world/";
      GENERIC_TIMEZONE = "Asia/Kolkata";
      NODE_FUNCTION_ALLOW_EXTERNAL = "*";
      NODE_FUNCTION_ALLOW_BUILTIN = "*";


      N8N_TEMPLATES_ENABLED = "true";
      # Don't phone home
      N8N_DIAGNOSTICS_ENABLED = "false";
      N8N_VERSION_NOTIFICATIONS_ENABLED = "false";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "/run/current-system/sw/bin/n8n";
      Restart = "on-failure";
      StateDirectory = "n8n";

      # Basic Hardening
      NoNewPrivileges = "yes";
      PrivateTmp = "yes";
      PrivateDevices = "yes";
      DevicePolicy = "closed";
      DynamicUser = "true";
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ProtectControlGroups = "yes";
      ProtectKernelModules = "yes";
      ProtectKernelTunables = "yes";
      RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
      RestrictNamespaces = "yes";
      RestrictRealtime = "yes";
      RestrictSUIDSGID = "yes";
      MemoryDenyWriteExecute = "no"; # v8 JIT requires memory segments to be Writable-Executable.
      LockPersonality = "yes";
    };
  };

















  services.nginx = {
    virtualHosts."n8n.${config.globals.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:5678";
        proxyWebsockets = true;
      };
    };
  };
}
