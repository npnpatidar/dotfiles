_: {
  flake.nixosModules.n8n = { config, ... }: {
    services.nginx.virtualHosts."n8n.${config.systemConstants.domain_name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:5678";
        proxyWebsockets = true;
        extraConfig = "client_max_body_size 1G;";
      };
    };
  };

  flake.homeModules.n8n = { config, inputs, ... }: {
    home.file."Data/podman/n8n/.keep".text = "";
    imports = [ inputs.quadlet-nix.homeManagerModules.quadlet ];
    virtualisation.quadlet.containers.n8n = {
      autoStart = true;
      serviceConfig = {
        RestartSec = "10";
        Restart = "always";
      };
      containerConfig = {
        image = "n8nio/n8n";
        publishPorts = [ "5678:5678" ];
        volumes = [ "/mnt/filen/Alma/services/n8n:/home/node/.n8n:Z" ];
        environments = {
          WEBHOOK_URL = "https://n8n.${config.systemConstants.domain_name}/";
          GENERIC_TIMEZONE = "Asia/Kolkata";
          NODE_FUNCTION_ALLOW_EXTERNAL = "*";
          NODE_FUNCTION_ALLOW_BUILTIN = "*";
          N8N_TEMPLATES_ENABLED = "true";
          N8N_DIAGNOSTICS_ENABLED = "false";
          N8N_VERSION_NOTIFICATIONS_ENABLED = "false";
          N8N_AVAILABLE_BINARY_DATA_MODES = "filesystem";
          N8N_FORMDATA_FILE_SIZE_MAX = "20000";
          N8N_PAYLOAD_SIZE_MAX = "20000";
          N8N_PROXY_HOPS = "1";
          N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS = "false";
          N8N_LOG_LEVEL = "debug";
        };
        userns = "keep-id";
      };
    };
  };
}
